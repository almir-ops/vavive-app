import { HttpClient } from '@angular/common/http';
import { Injectable, NgZone } from '@angular/core';
import { Router, NavigationEnd } from '@angular/router';
import { Observable, tap, take, switchMap } from 'rxjs';
import { environment } from 'src/environments/environment.prod';
import { LoginToken } from './login-token';
import { Token } from './token';
import { IUser } from 'src/app/shared/interfaces/uUser';
import { ApiService } from 'src/app/shared/services/api.service';
import { Storage } from '@ionic/storage-angular';
import { Preferences } from '@capacitor/preferences';

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  private endpoint = `${environment.baseUrl}`;

  private token?: LoginToken;

  private lastUrl!: string;

  constructor(
    private httpClient: HttpClient,
    private router: Router,
    private ngZone: NgZone,
    private apiService: ApiService,
    private storage: Storage,

    ) {

    this.lastUrl = btoa('/');
    this.router.events.subscribe(e => {
      if (e instanceof NavigationEnd) {
        this.lastUrl = btoa(e.url);
      }
    });
    this.loadCredentials();

   }

   login(user: IUser, paramUser: any): Observable<Token> {
    return this.apiService.loadApiUrl().pipe(
      switchMap((apiUrl: string) => {
        return this.httpClient.post<Token>(`https://${apiUrl}/api/v1/${paramUser}/sign`, user).pipe(
          tap((token: Token) => this.registerCredentials(token)),
          take(1)
        );
      })
    );
  }



  logout(){
    localStorage.clear();
    this.storage.clear();
    Preferences.clear();
    this.router.navigate(['select-region']);
    this.unRegisterCredentials();
  }


  isLoggedIn(): boolean {
    return this.loadCredentials();
  }


  handleLoggin(path: string = this.lastUrl): void {
    //this.router.navigate(['/login', atob(path)]);
    this.router.navigate(['account/sign']);
  }

  private registerCredentials(token: Token): void {
    if(token !== null){
      this.token = new LoginToken(token);
      localStorage.setItem('token', token['access_token']);
      this.router.navigate(['/start']);
    }
  }

  private loadCredentials(): boolean {

    if (this.token === undefined) {
      const token = localStorage.getItem('token');

      if (token) {

        this.token = new LoginToken({ access_token: token });
      }
    }
    const loaded: boolean = !!this.token && this.token.isValid;

    if (!loaded) {
      this.unRegisterCredentials();
    }

    return loaded;
  }

  get obterUsuarioLogado(): IUser | null {
    const usuario = localStorage.getItem('user');

    return usuario
      ? JSON.parse(atob(usuario))
      : null;
  }


  private unRegisterCredentials(): void {
    this.token = undefined;
    localStorage.removeItem('token');
  }

  get obterTokenUsuario(): any {
    const token = localStorage.getItem('token')
    if(token != null || undefined){
      return token!
      }
    else{
      return null
    }
  }

  logged(): boolean {
    return localStorage.getItem('token') ? true : false;
  }

  getName(): string | undefined {
    return this.token?.name;
  }

  getToken(): string | undefined {
    return this.token?.jwtToken;
  }

  saveNewPassword(pass: any, paramUser: any): Observable<Token> {
    const cpf = localStorage.getItem('cpfUser');
    const encoded = btoa(cpf + ':' + pass);
    return this.apiService.loadApiUrl().pipe(
      switchMap(url =>
        this.httpClient.post<Token>(`https://${url}/api/v1/${paramUser}/updatepass`, encoded)
      ),
      take(1)
    );
  }

  forgotPassword(data: any, route: any): Observable<Token> {
    return this.apiService.loadApiUrl().pipe(
      switchMap(apiUrl =>
        this.httpClient.post<Token>(`https://${apiUrl}/api/v1/${route}/forgot`, data)
      ),
      take(1)
    );
  }

  getInfoUser(paramUser: any): Observable<any> {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url =>
        this.httpClient.get<any>(`https://${url}/api/v1/${paramUser}/me`)
      ),
      take(1)
    );
  }

  registerNewUser(user: any, paramUser: any): Observable<Token> {
    return this.apiService.loadApiUrl().pipe(
      switchMap(url =>
        this.httpClient.post<Token>(`https://${url}/api/v1/${paramUser}/signup`, user)
      ),
      take(1)
    );
  }

}

