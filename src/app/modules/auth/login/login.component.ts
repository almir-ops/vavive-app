import { Component, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { AbstractControl, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../auth.service';
import { IUser } from 'src/app/shared/interfaces/uUser';
import { AlertComponent } from 'src/app/shared/components/alert/alert.component';
import { LoadingComponent } from 'src/app/shared/components/loading/loading.component';
import { AlertService } from 'src/app/shared/services/alert.service';
import { Storage } from '@ionic/storage-angular';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss'],
})
export class LoginComponent  implements OnInit{

  styleBorderUser: any = '';
  formLogin!: FormGroup;
  hiddenPassword: boolean = false;
  public actionSheetButtons = [
    {
      text: 'Cliente',
      handler: () => {
        this.navegateByParam('account/register', 'Cliente');
      }
    },
    {
      text: 'Empresa',
      handler: () => {
        this.navegateByParam('account/register', 'Empresa');
      }
    },
    /*
    {
      text: 'Profissional',
      handler: () => {
        this.navegate('account/register', 'Profissional');
      }
    }*/
  ];
  @ViewChild('alertComponent') alertComponent!: AlertComponent;
  @ViewChild('loadingComponent') loadingComponent!: LoadingComponent;
  paramUser = 'clientes'

  currentFranquia: any;

  constructor(
    private formBuilder: FormBuilder,
    private router: Router,
    private authService: AuthService,
    private alertService: AlertService,
    private storage:Storage
  ) { }

  ngOnInit() {

    this.createForm();
    this.getFranquiaInfo();
  }

  createForm(){
    this.formLogin = this.formBuilder.group({
      username:['', Validators.required],
      password:['', Validators.required],
    })
  }

  get formLoginControl(): { [key: string]: AbstractControl } {
    return this.formLogin.controls;
  }

  async getFranquiaInfo(){
    const franquia = await this.storage.get('franquia');
    this.currentFranquia = franquia
    console.log(franquia);

  }

  showAlertUser() {
    const { username } = this.formLogin.getRawValue();
  }


  viewPassword() {
    this.hiddenPassword = !this.hiddenPassword;
  }

  login(){
    const user: IUser = {
      email: this.formLogin.controls['username'].value,
      password: this.formLogin.controls['password'].value,
    };

    this.authService.login(user,this.paramUser).subscribe({
      next: (response:any) => {
        console.log(response);
        this.storage.set('param_user', this.paramUser)
      },error: (err) =>{
        console.log(err)
        if(err.status === 404){
          this.alertService.presentAlert('Erro ', `Conta não encontrada`);
        }else{
          this.alertService.presentAlert('Erro ', `${err.error.detail}`);
        }

        if(err === '500'){

        }
      }
  })
  }

  showLoading() {
    this.loadingComponent.createLoading();
  }

  hideLoading() {
    this.loadingComponent.dismissLoading();
  }

  navegateByParam(rota: string, tipo: string) {
    this.router.navigate([rota], { queryParams: { tipo: tipo } });
  }

  navegate(rota: string) {
    this.router.navigate([rota]);
  }


  navigateToForgotPass() {
    this.router.navigate(['account/forgot']);
  }
}
