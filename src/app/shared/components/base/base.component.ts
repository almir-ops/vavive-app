import { HttpClient } from '@angular/common/http';
import { Directive, inject } from '@angular/core';
import { FormGroup, FormBuilder, AbstractControl } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { AuthService } from 'src/app/modules/auth/auth.service';
import { AlertService } from '../../services/alert.service';
import { Storage } from '@ionic/storage-angular';

type ControllType = AbstractControl<any, any> | null;

@Directive()
export abstract class BaseComponent {
  public form!: FormGroup;
  public fb: FormBuilder = inject(FormBuilder);
  public router: Router = inject(Router);
  public route: ActivatedRoute = inject(ActivatedRoute);
  public loading: boolean = false;
  public http: HttpClient = inject(HttpClient);
  public authService: AuthService = inject(AuthService);
  public alertService: AlertService = inject(AlertService);
  public storage: Storage = inject(Storage);
  

  public isErrorRequired(controll_name: string) {
    return this.getControll(controll_name)?.errors?.['required'];
  }

  get formControlls(): { [key: string]: AbstractControl } {
    return this.form.controls;
  }

  notify(
    header: string,
    msg: string
  ) {
    this.alertService.presentAlert(header, msg);
  }

  public redirectTo(route: string, tipo: string): void {
    this.router.navigate([route], { queryParams: { tipo: tipo } });
  }

  public validateFirstInvalidField() {
    const form = this.form;
    console.log(form);
    for (const field of Object.keys(form.controls)) {
      const control = form.get(field);

      if (control && control.invalid) {
        control.markAsTouched();
        control.updateValueAndValidity();
        break;
      }
    }
  }

  private getControll(control: string): ControllType {
    return this.form.get(control);
  }
}
