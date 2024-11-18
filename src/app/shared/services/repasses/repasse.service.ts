import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { switchMap } from 'rxjs';
import { environment } from 'src/environments/environment';
import { ApiService } from '../api.service';

@Injectable({
  providedIn: 'root'
})
export class RepasseService {

  constructor(private httpClient: HttpClient, private apiService: ApiService) { }

  getRepasses(){
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpClient.get(`https://${url}/api/v1/repasses`))
    );
  }

  getRepassesByFilters(query:any){
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpClient.get(`https://${url}/api/v1/repasses`+ query))
    );
  }

  getValorAtendimento(grupo: string, duracao: string): Promise<number> {
    return this.httpClient.get<number>(`/api/valores?grupo_repasse=${grupo}&duracao=${duracao}`)
      .toPromise()
      .then(response => response || 0)
      .catch(error => {
        console.error('Erro ao buscar valor na API:', error);
        return 0;
      });
  }
}
