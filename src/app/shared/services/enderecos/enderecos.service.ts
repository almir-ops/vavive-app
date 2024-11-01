import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { switchMap } from 'rxjs';
import { environment } from 'src/environments/environment';
import { ApiService } from '../api.service';

@Injectable({
  providedIn: 'root'
})
export class EnderecosService {

  constructor(private httpClient: HttpClient, private apiService: ApiService) { }

  putEndereco(endereco: any) {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpClient.put(`https://${url}/api/v1/endereco/${endereco.ID}`, endereco))
    );
  }

  deleteEndereco(endereco: any) {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpClient.delete(`https://${url}/api/v1/endereco/${endereco.ID}`))
    );
  }

}
