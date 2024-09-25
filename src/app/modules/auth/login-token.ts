import { BehaviorSubject, Observable } from 'rxjs';
import { Token } from './token';


export class LoginToken {
  private loginSubject: BehaviorSubject<LoginToken>;

  private expToken: Date = new Date(0);
  private iatToken: Date = new Date(0);
  private tenantIdToken: number;
  private subjectToken: string;

  constructor(private accessToken: any) {
    console.log(accessToken);

    const payload = JSON.parse(
      atob(accessToken.access_token.split('.')[TokenParts.Payload])
    );
    this.tenantIdToken = Number(payload['tenantid']);
    this.subjectToken = String(payload['sub']);
    this.iatToken.setUTCSeconds(payload['iat']);
    this.expToken.setUTCSeconds(payload['exp']);
    this.loginSubject = new BehaviorSubject<LoginToken>(this);
  }

  get tenantId(): number{
    return this.tenantIdToken;
  }

  get expiration(): Date {
    return this.expToken;
  }

  get issuedAt(): Date {
    return this.iatToken;
  }

  get isValid(): boolean {
    return new Date().valueOf() < this.expToken.valueOf();
  }

  get jwtToken(): string {
    return this.accessToken.authorization;
  }

  get name(): string {
    return this.subjectToken;
  }

  getLoginSubject(): Observable<LoginToken> {
    return this.loginSubject.asObservable();
  }
}

enum TokenParts {
  Header,
  Payload,
  Sign,
}
