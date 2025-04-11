import { Component, OnInit, ViewChild } from '@angular/core';
import { Validators } from '@angular/forms';
import { AlertComponent } from 'src/app/shared/components/alert/alert.component';
import { LoadingComponent } from 'src/app/shared/components/loading/loading.component';
import { IonModal } from '@ionic/angular';
import { BaseComponent } from 'src/app/shared/components/base/base.component';

@Component({
  selector: 'app-forgot-password',
  templateUrl: './forgot-password.component.html',
  styleUrls: ['./forgot-password.component.scss'],
})
export class ForgotPasswordComponent extends BaseComponent implements OnInit {
  @ViewChild('alertComponent') alertComponent!: AlertComponent;
  @ViewChild('loadingComponent') loadingComponent!: LoadingComponent;
  @ViewChild('modalSendEmail', { static: false }) modalSendEmail!: IonModal;

  public actionSheetButtons = [
    {
      text: 'Cliente',
      handler: () => {
        this.redirectTo('account/register', 'Cliente');
      },
    },
    {
      text: 'Empresa',
      handler: () => {
        this.redirectTo('account/register', 'Empresa');
      },
    },
    {
      text: 'Profissional',
      handler: () => {
        this.redirectTo('account/register', 'Profissional');
      },
    },
  ];

  frontUrl: any;

  ngOnInit() {
    this.createForm();
    this.initializeApp();
  }

  async initializeApp() {
    this.frontUrl = await this.storage.get('front_url');
  }

  createForm() {
    this.form = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
    });
  }

  showLoading() {
    this.loadingComponent.createLoading();
  }

  hideLoading() {
    this.loadingComponent.dismissLoading();
  }

  navigateToAccountSign() {
    this.router.navigate(['account/sign']);
  }

  onSubmit() {
    const user: any = {
      email: this.form.controls['email'].value,
      url: 'https://' + this.frontUrl + '/admin/reset/cliente',
    };

    this.authService
      .forgotPassword({ url: user.url, email: user.email }, 'clientes')
      .subscribe({
        next: (response: any) => {
          this.notify(
            'Email enviado com sucesso ',
            `Verifique sua caixa de email ou spam e siga as instruções!`
          );
        },
        error: (err) => {
          this.notify(
            'Erro ao enviar email ',
            err.error.detail
          );
        },
      });
  }
}
