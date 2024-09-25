import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { environment } from 'src/environments/environment';

@Injectable({
  providedIn: 'root'
})
export class PagamentosService {

  baseUrl = environment.baseUrl;

  constructor(private httpClient: HttpClient) { }

  criaPagamento(pagamento:any){
    return this.httpClient.post(this.baseUrl+ 'payment/asaas', pagamento);
  }
}
