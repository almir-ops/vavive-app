import { Injectable, ViewChild } from '@angular/core';
import {
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpInterceptor,
  HttpErrorResponse
} from '@angular/common/http';
import { Observable, catchError, throwError } from 'rxjs';
import { AuthService } from 'src/app/modules/auth/auth.service';
import { AlertComponent } from 'src/app/shared/components/alert/alert.component';
import { AlertController } from '@ionic/angular';

@Injectable()
export class TokenProviderInterceptor implements HttpInterceptor {

  domain: string;
  @ViewChild('alertComponent') alertComponent!: AlertComponent;

  constructor(private authService: AuthService, private alertController: AlertController) {
    this.domain = window.location.hostname;
  }

  intercept(request: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {

    const accessToken = this.authService.obterTokenUsuario

    if (accessToken) {
      let authReq = request;
      authReq = request.clone({
        setHeaders: { Authorization: `Bearer ${accessToken}`,
      },
      });
      return next.handle(authReq);
    }


    return next.handle(request);

  }

  private handleError(error: HttpErrorResponse) {


    if (error.error instanceof ErrorEvent) {

      console.error('Ocorreu um erro: ', error.error.message);

    } else {

      console.error(
        `Código do erro ${error.status}, ` +
        `Erro: ${JSON.stringify(error.error)}`);

    }

    return throwError(JSON.stringify(`${error.status}`));

  }


}
