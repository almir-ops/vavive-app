import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import * as moment from 'moment';
import { map, switchMap } from 'rxjs';
import { environment } from 'src/environments/environment';
import { ApiService } from '../api.service';

@Injectable({
  providedIn: 'root'
})
export class AtendimentosService {

  baseUrl = environment.baseUrl;

  constructor(
    private httpClient: HttpClient,
    private apiService: ApiService
  ) { }

  getAttendences(page: any, size: any) {
    console.log(page);

    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpClient.get(`https://${url}/api/v1/atendimentos?page=${page}&page_size=${size}`)),
      map((response: any) => {
        const currentTime = moment();

        response.items.forEach((atendimento: any) => {
          const atendimentoTime = moment(atendimento.hora_de_entrada, 'HH:mm');
          const isToday = moment(atendimento.data_inicio).isSame(moment(), 'day');

          if (isToday && atendimento.status_atendimento === 'Pendente' && atendimentoTime.isBefore(currentTime)) {
            atendimento.status_atendimento = 'Atrasado';
          }
        });

        return response;
      })
    );
  }

  getAttendencesByFilters(query: any) {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpClient.get(`https://${url}/api/v1/atendimentos${query}`)),
      map((response: any) => {
        const currentTime = moment();

        response.items.forEach((atendimento: any) => {
          const atendimentoTime = moment(atendimento.hora_de_entrada, 'HH:mm');
          const isToday = moment(atendimento.data_inicio).isSame(moment(), 'day');

          if (isToday && atendimento.status_atendimento === 'Pendente' && atendimentoTime.isBefore(currentTime)) {
            atendimento.status_atendimento = 'Atrasado';
          }
        });

        return response;
      })
    );
  }

  filterAtendimentos(param: any, date: any) {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpClient.get(`https://${url}/api/v1/atendimentos?${param}=${date}`))
    );
  }

  saveListAtendimentos(atendimentos: any) {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpClient.post(`https://${url}/api/v1/atendimentos/all`, atendimentos))
    );
  }

  putAttendence(atendimento: any) {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpClient.put(`https://${url}/api/v1/atendimentos/one/${atendimento.ID}`, atendimento))
    );
  }

}
