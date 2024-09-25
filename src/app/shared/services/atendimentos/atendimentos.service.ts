import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import * as moment from 'moment';
import { map, switchMap } from 'rxjs';
import { environment } from 'src/environments/environment';

@Injectable({
  providedIn: 'root'
})
export class AtendimentosService {

  baseUrl = environment.baseUrl;

  constructor(private httpClient: HttpClient) { }

  getAttendences(page: any, size: any) {
    console.log(page);

    return this.httpClient.get(this.baseUrl + 'atendimentos?page=' + page + '&page_size=' + size)
      .pipe(
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

  getAttendencesByFilters(query:any){
    return this.httpClient.get(this.baseUrl+ 'atendimentos'+ query).pipe(
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

  filterAtendimentos(param:any,date:any) {
    const url = this.baseUrl + 'atendimentos?' +param+'='+date;
    return this.httpClient.get(url);
  }

  saveListAtendimentos(atendimentos:any){
    return this.httpClient.post(this.baseUrl+ 'atendimentos/all', atendimentos);
  }

  putAttendence(atendimento:any){
    return this.httpClient.put(this.baseUrl+ 'atendimentos/one/'+ atendimento.ID, atendimento);
  }
}
