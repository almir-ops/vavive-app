import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { switchMap } from 'rxjs/operators';
import { ApiService } from '../api.service';

@Injectable({
  providedIn: 'root'
})
export class CuponsService {

  constructor(private httpClient: HttpClient, private apiService: ApiService) {

  }

  putCupons(cupom: any): Observable<any> {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => this.httpClient.put(`https://${url}/api/v1/cupons/${cupom.ID}`, cupom))
    );
  }

  getCuponsByFilters(query: any): Observable<any> {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url => {
        const fullUrl = `https://${url}/api/v1/cupons${query}`;
        console.log('Request URL:', fullUrl);  // Log da URL completa
        return this.httpClient.get(fullUrl);
      })
    );
  }

}
