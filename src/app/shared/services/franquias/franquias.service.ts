import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class FranquiasService {

  private apiUrl = 'https://vavive-go-production.up.railway.app/api/v1/franquias';

  constructor(private http: HttpClient) { }

  // Método para fazer o GET e obter os dados das franquias
  getFranquias(): Observable<any> {
    return this.http.get<any>(this.apiUrl);
  }
}
