import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import * as moment from 'moment';
import { Observable, forkJoin, map, switchMap } from 'rxjs';
import { environment } from 'src/environments/environment';
import { ApiService } from '../api.service';

@Injectable({
  providedIn: 'root'
})
export class FinancasService {
  currentState: any;
  domain: any;

  constructor(private httpClient: HttpClient, private apiService: ApiService) {
    this.domain = window.location.hostname;
  }


  getFinancasByFilter(filter: string){
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpClient.get(`https://${url}/api/v1/financas` + filter))
    );
  }

  getRecebidosByDatesAndFilter(dataDe: any, dataAte: any, queryString: any) {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpClient.get(`https://${url}/api/v1/financas`+ 'financas?de=' + dataDe + '&ate=' + dataAte + '&tipo=Entrada'+ queryString ))
    );
  }

  getRPagamentosByDatesAndFilter(dataDe: any, dataAte: any, queryString: any) {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpClient.get(`https://${url}/api/v1/financas` + '?de=' + dataDe + '&ate=' + dataAte + '&tipo=Repasse' + queryString ))
    )
  }

  postFinancas(financas: any) {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpClient.post(`https://${url}/api/v1/financas`, financas))
    );
  }

  putFinancas(financa: any) {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpClient.put(`https://${url}/api/v1/financas` + financa.ID, financa))
    );
  }

  deleteFinancas(financa: any) {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpClient.delete(`https://${url}/api/v1/financas` + financa.ID, { responseType: 'text' }))
    );
  }

}
