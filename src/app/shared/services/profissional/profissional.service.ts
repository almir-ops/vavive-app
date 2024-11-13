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
      switchMap(url => this.httpCliente.post(`${url}/signup`, profissional))
    );
  }

  updateClient(profissional: any) {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpCliente.put(`${url}/${profissional.ID}`, profissional))
    );
  }

}
