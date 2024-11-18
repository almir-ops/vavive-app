import { Component, OnInit, ViewChild } from '@angular/core';
import { FormGroup, FormBuilder, Validators, AbstractControl } from '@angular/forms';
import { Router } from '@angular/router';
import { AlertComponent } from 'src/app/shared/components/alert/alert.component';
import { LoadingComponent } from 'src/app/shared/components/loading/loading.component';
import { IUser } from 'src/app/shared/interfaces/uUser';
import { AuthService } from '../auth.service';
import { Storage } from '@ionic/storage-angular';
import { IonModal } from '@ionic/angular';
import { AlertService } from 'src/app/shared/services/alert.service';

@Component({
  selector: 'app-forgot-password',
  templateUrl: './forgot-password.component.html',
  styleUrls: ['./forgot-password.component.scss'],
})
export class ForgotPasswordComponent  implements OnInit {

  styleBorderUser: any = '';
  formForgotPass!: FormGroup;
  hiddenPassword: boolean = false;
  public actionSheetButtons = [
    {
      text: 'Cliente',
      handler: () => {
        this.navegate('account/register', 'Cliente');
      }
    },
    {
      text: 'Empresa',
      handler: () => {
        this.navegate('account/register', 'Empresa');
      }
    },
    {
      text: 'Profissional',
      handler: () => {
        this.navegate('account/register', 'Profissional');
      }
    }
  ];
  @ViewChild('alertComponent') alertComponent!: AlertComponent;
  @ViewChild('loadingComponent') loadingComponent!: LoadingComponent;
  @ViewChild('modalSendEmail', { static: false }) modalSendEmail!: IonModal;

  paramUser = 'clientes'
  frontUrl: any;
  constructor(
    private formBuilder: FormBuilder,
    private router: Router,
    private authService: AuthService,
    private storage: Storage,
    private alertService: AlertService,


  ) { }

  ngOnInit() {
    this.createForm();
    this.initializeApp();
  }
  async initializeApp() {

    this.frontUrl = await this.storage.get('front_url');

  }

  createForm(){
    this.formForgotPass = this.formBuilder.group({
      email:['', Validators.required],
    })
  }

  get formLoginControl(): { [key: string]: AbstractControl } {
    return this.formForgotPass.controls;
  }


  showAlertUser() {
    const { username } = this.formForgotPass.getRawValue();

  }

  enableBtnLogin(){

  }

  viewPassword() {
    this.hiddenPassword = !this.hiddenPassword;
  }

  showLoading() {
    this.loadingComponent.createLoading();
  }

  hideLoading() {
    this.loadingComponent.dismissLoading();
  }

  navegate(rota: string, tipo: string) {
    this.router.navigate([rota], { queryParams: { tipo: tipo } });
  }

  navigateToAccountSign() {
    this.router.navigate(['account/sign']);
  }

  onSubmit() {
    const user: any = {
      email: this.formForgotPass.controls['email'].value,
      url: 'https://'+ this.frontUrl + '/admin/reset/cliente'
    };
    this.authService.forgotPassword(user.url, user.email, 'clientes').subscribe({
        next: (response:any) => {
          console.log(response);
          this.alertService.presentAlert('Email enviado com sucesso ', `Verifique sua caixa de email ou span e siga as instruções!`);
        },error: (err) =>{
          this.alertService.presentAlert('Erro ao enviar email ', `Houve erro ao enviar o email verifique se o mesmo esta cadastrado e tente novamente.`);
          console.log(err);
        },
        complete: () =>{
          console.log('complete');
        }
    })
  }
}
