import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { environment } from 'src/environments/environment';
import { uCliente } from '../../interfaces/uCliente';
import { switchMap } from 'rxjs';
import { ApiService } from '../api.service';

@Injectable({
  providedIn: 'root'
})
export class ClientesService {

  private endpoint = `${environment.baseUrl}clientes`;

  constructor(private httpCliente: HttpClient, private apiService: ApiService) { }

  createClient(cliente: uCliente) {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpCliente.post(`${url}/signup`, cliente))
    );
  }

  updateClient(cliente: uCliente) {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpCliente.put(`${url}/${cliente.ID}`, cliente))
    );
  }

}
