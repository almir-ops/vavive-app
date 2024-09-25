import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ViacepService {

  private viacepUrl: string = 'https://viacep.com.br/ws';

  constructor(private http: HttpClient) { }

  // Método para buscar o endereço pelo CEP
  buscarEndereco(cep: string): Observable<any> {
    // Retorna o resultado da API ViaCEP no formato JSON
    return this.http.get<any>(`${this.viacepUrl}/${cep}/json`);
  }
}
