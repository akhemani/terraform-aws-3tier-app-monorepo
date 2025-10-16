import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RegisterUserComponent } from '../register-user/register-user';
import { ListUsersComponent } from '../list-users/list-users';
import { ApiService } from '../api';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, RegisterUserComponent, ListUsersComponent],
  templateUrl: './home.html',
  styleUrls: ['./home.css']
})
export class HomeComponent {
  welcomeMessage = '';
  users: string[] = [];

  constructor(private api: ApiService) {}

  ngOnInit(): void {
    this.loadWelcome();
    this.loadUsers();
  }

  loadWelcome(): void {
    this.api.getWelcome().subscribe({
      next: res => this.welcomeMessage = res,
      error: () => this.welcomeMessage = '❌ Backend not reachable'
    });
  }

  loadUsers(): void {
    this.api.getAllUsers().subscribe({
      next: res => this.users = res,
      error: () => this.users = []
    });
  }

  onUserAdded(): void {
    this.loadUsers();
  }
}
