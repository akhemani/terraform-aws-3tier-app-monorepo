import { Component, EventEmitter, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../api';

@Component({
  selector: 'app-register-user',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './register-user.html',
  styleUrls: ['./register-user.css']
})
export class RegisterUserComponent {
  @Output() userAdded = new EventEmitter<void>();
  name = '';

  constructor(private api: ApiService) {}

  addUser(): void {
    const trimmed = this.name.trim();
    if (!trimmed) return;
    this.api.addUser(trimmed).subscribe({
      next: () => {
        this.name = '';
        this.userAdded.emit();
      },
      error: () => alert('Error adding user')
    });
  }
}
