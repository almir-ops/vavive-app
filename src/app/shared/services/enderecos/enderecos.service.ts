import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { environment } from 'src/environments/environment';

@Injectable({
  providedIn: 'root'
})
export class EnderecosService {

  baseUrl = environment.baseUrl;

  constructor(private httpClient: HttpClient) { }

  putEndereco(endereco:any){
    return this.httpClient.put(this.baseUrl + 'endereco/'+ endereco.ID, endereco);
  }

  deleteEndereco(endereco:any){
    return this.httpClient.delete(this.baseUrl + 'endereco/'+ endereco.ID);
  }
}
