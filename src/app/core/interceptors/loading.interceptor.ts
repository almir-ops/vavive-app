import { HttpInterceptor, HttpRequest, HttpHandler, HttpEvent } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { Observable, finalize } from "rxjs";
import { LoadingService } from "src/app/shared/services/loading/loading.service";

@Injectable()
export class LoadingInterceptor implements HttpInterceptor {

  constructor(private loadingService: LoadingService) {}

  intercept(request: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    console.log('[LoadingInterceptor] Iniciando requisição:', request.url);

    // Exibe o loading se não houver nenhum ativo
    this.loadingService.showLoading(); // Sempre chama showLoading

    // Processa a requisição normalmente
    return next.handle(request).pipe(
      finalize(() => {
        console.log('[LoadingInterceptor] Finalizando requisição:', request.url);

        // Quando todas as requisições finalizam, esconde o loading
        this.loadingService.hideLoading();
      })
    );
  }
}
