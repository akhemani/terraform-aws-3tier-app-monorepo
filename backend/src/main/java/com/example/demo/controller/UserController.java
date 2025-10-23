package com.example.demo.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;

import java.util.List;
import java.util.stream.Collectors;

@RestController
public class UserController {

    // Create a logger instance for this class
    private static final Logger logger = LoggerFactory.getLogger(UserController.class);

    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    // 1️⃣ Welcome API
    @GetMapping
    public String welcome() {
        logger.info("Welcome API called");  // Log the call to this API
        return "Welcome to Spring Boot + PostgreSQL demo!";
    }

    // 2️⃣ Register user
    @PostMapping("/user")
    public String addUser(@RequestBody User user) {
        logger.info("Add User API called with user: {}", user.getName());  // Log the user being added
        userRepository.save(user);
        return "User added successfully!";
    }

    // 3️⃣ Get all users
    @GetMapping("/users")
    public List<String> getAllUsers() {
        logger.info("Fetching all users...");  // Log when the endpoint is hit
        List<String> users = userRepository.findAll().stream().map(User::getName).collect(Collectors.toList());
        logger.info("Fetched users: {}", users);  // Log the fetched users
        return users;
    }
}
