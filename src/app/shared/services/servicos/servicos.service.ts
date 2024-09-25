import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment.prod';

@Injectable({
  providedIn: 'root'
})
export class ServicosService {

  private apiUrl = `${environment.baseUrl}servicos`;

  constructor(private http: HttpClient) { }

  // Método para fazer o GET e obter os dados das franquias
  getServicos(): Observable<any> {
    return this.http.get<any>(this.apiUrl);
  }
}
