import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-list-users',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './list-users.html',
  styleUrls: ['./list-users.css']
})
export class ListUsersComponent {
  @Input() users: string[] = [];
}
