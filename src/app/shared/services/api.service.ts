import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Storage } from '@ionic/storage-angular';
import { from, Observable } from 'rxjs';
import { switchMap } from 'rxjs/operators';

@Injectable({
  providedIn: 'root',
})
export class ApiService {
  apiUrl!: string;

  constructor(private http: HttpClient, private storage: Storage) {}

  // Método para garantir que a URL está carregada antes de qualquer requisição
  loadApiUrl(): Observable<string> {
    return from(this.storage.get('api_url')).pipe(
      switchMap((url: string) => {
        this.apiUrl = url;
        return from([url]);
      })
    );
  }

  // Método para GET
  getData(endpoint: string): Observable<any> {
    return this.loadApiUrl().pipe(
      switchMap((url: string) => {
        return this.http.get(`${url}/${endpoint}`);
      })
    );
  }

  // Método para POST
  postData(endpoint: string, body: any): Observable<any> {
    return this.loadApiUrl().pipe(
      switchMap((url: string) => {
        return this.http.post(`${url}/${endpoint}`, body);
      })
    );
  }
}
