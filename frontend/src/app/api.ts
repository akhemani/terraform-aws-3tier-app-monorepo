import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private baseUrl = 'https://api.learnforge.site'; // backend URL

  constructor(private http: HttpClient) {}

  getWelcome(): Observable<string> {
    return this.http.get(`${this.baseUrl}`, { responseType: 'text' });
  }

  addUser(name: string): Observable<string> {
    return this.http.post(`${this.baseUrl}/user`, { name }, { responseType: 'text' });
  }

  getAllUsers(): Observable<string[]> {
    return this.http.get<string[]>(`${this.baseUrl}/users`);
  }
}
