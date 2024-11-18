import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { switchMap } from 'rxjs';
import { environment } from 'src/environments/environment';
import { uCliente } from '../../interfaces/uCliente';
import { ApiService } from '../api.service';

@Injectable({
  providedIn: 'root'
})
export class ProfissionalService {

  private endpoint = `${environment.baseUrl}profissional`;

  constructor(private httpCliente: HttpClient, private apiService: ApiService) { }

  createClient(profissional: any) {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpCliente.post(`https://${url}/api/v1/profissionais/signup`, profissional))
    );
  }

  putProfissional(profissional: any) {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpCliente.put(`https://${url}/api/v1/profissionais/${profissional.ID}`, profissional))
    );
  }

  calcularValorRepasses(horario: string, grupo: string): number {
    let valorHora = 0;
    const auxilioPassagens = 10.0;

    switch (grupo) {
      case "1":
        valorHora = this.obterValorHoraGrupo1(horario);
        break;
      case "2":
        valorHora = this.obterValorHoraGrupo2(horario);
        break;
      case "3":
        valorHora = this.obterValorHoraGrupo3(horario);
        break;
      default:
        console.log('Grupo inválido.');
        return 0;
    }

    if (valorHora === 0) {
      console.log('Horário inválido.');
      return 0;
    }

    return valorHora + auxilioPassagens;
  }

  private obterValorHoraGrupo1(horario: string): number {
    switch (horario) {
      case '09:00':
        return 106;
      case '08:00':
        return 100;
      case '07:00':
        return 92;
      case '06:00':
        return 85;
      case '05:00':
        return 75;
      case '04:00':
        return 65;
      case '03:00':
        return 55;
      case '02:00':
        return 45;
      default:
        return 0;
    }
  }

  private obterValorHoraGrupo2(horario: string): number {
    switch (horario) {
      case '09:00':
        return 101;
      case '08:00':
        return 95;
      case '07:00':
        return 87;
      case '06:00':
        return 80;
      case '05:00':
        return 70;
      case '04:00':
        return 60;
      case '03:00':
        return 50;
      case '02:00':
        return 40;
      default:
        return 0;
    }
  }

  private obterValorHoraGrupo3(horario: string): number {
    switch (horario) {
      case '09:00':
        return 111;
      case '08:00':
        return 105;
      case '07:00':
        return 97;
      case '06:00':
        return 90;
      case '05:00':
        return 85;
      case '04:00':
        return 75;
      case '03:00':
        return 65;
      case '02:00':
        return 55;
      default:
        return 0;
    }
  }
}
