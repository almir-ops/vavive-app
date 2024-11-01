import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable, switchMap } from 'rxjs';
import { environment } from 'src/environments/environment.prod';
import { ApiService } from '../api.service';

@Injectable({
  providedIn: 'root'
})
export class ServicosService {

  private apiUrl = `${environment.baseUrl}servicos`;

  constructor(private http: HttpClient, private apiService: ApiService) { }

  getServicos(): Observable<any> {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.http.get<any>(`https://${url}/api/v1/servicos`))
    );
  }
}
