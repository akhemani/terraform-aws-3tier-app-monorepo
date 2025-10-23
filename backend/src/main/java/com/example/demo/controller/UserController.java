package com.example.demo.controller;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;

@CrossOrigin(origins = "*")  // Allow all origins, replace "*" with your frontend URL for production
@RestController
public class UserController {

    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    // 1️⃣ Welcome API
    @GetMapping
    public String welcome() {
        return "Welcome to Spring Boot + PostgreSQL demo!";
    }

    // 2️⃣ Register user
    @PostMapping("/user")
    public String addUser(@RequestBody User user) {
        userRepository.save(user);
        return "User added successfully!";
    }

    // 3️⃣ Get all users
    @GetMapping("/users")
    public List<String> getAllUsers() {
        return userRepository.findAll().stream().map(User::getName).collect(Collectors.toList());
    }
}
