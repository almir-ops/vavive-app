// api.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Storage } from '@ionic/storage-angular';

@Injectable({
  providedIn: 'root',
})
export class ApiService {
  apiUrl!: string;

  constructor(private http: HttpClient, private storage: Storage) {
    this.loadApiUrl();
  }

  async loadApiUrl() {
    this.apiUrl = await this.storage.get('api_url');
  }

  getData(endpoint: string) {
    return this.http.get(`${this.apiUrl}/${endpoint}`);
  }
}
