import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { environment } from 'src/environments/environment';
import { uCliente } from '../../interfaces/uCliente';

@Injectable({
  providedIn: 'root'
})
export class ClientesService {

  private endpoint = `${environment.baseUrl}clientes`;

  constructor(private httpCliente: HttpClient) { }

  createClient(cliente:uCliente){
    return this.httpCliente.post(this.endpoint + '/signup', cliente);
  }

  updateClient(cliente:uCliente){
    return this.httpCliente.put(this.endpoint + '/'+cliente.ID, cliente);
  }
}
