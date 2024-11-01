import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { switchMap } from 'rxjs';
import { environment } from 'src/environments/environment';
import { ApiService } from '../api.service';

@Injectable({
  providedIn: 'root'
})
export class PagamentosService {

  constructor(private httpClient: HttpClient, private apiService: ApiService) { }

  criaPagamento(pagamento: any) {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpClient.post(`https://${url}/api/v1/payment/asaas`, pagamento))
    );
  }

}
