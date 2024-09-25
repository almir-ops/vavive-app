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
  paramUser = 'clientes'
  constructor(
    private formBuilder: FormBuilder,
    private router: Router,
    private authService: AuthService,
    private alertService: AlertService,
    private storage:Storage
  ) { }

  ngOnInit() {
    this.createForm();
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


  showAlertUser() {
    const { username } = this.formLogin.getRawValue();

  }

  enableBtnLogin(){

  }

  viewPassword() {
    this.hiddenPassword = !this.hiddenPassword;
  }

  login(){
    const user: IUser = {
      email: this.formLogin.controls['username'].value,
      password: this.formLogin.controls['password'].value,
    };
    this.showLoading();

    this.authService.login(user,this.paramUser).subscribe({
      next: (response:any) => {
        console.log(response);
        this.storage.set('param_user', this.paramUser)
        this.hideLoading();
      },error: (err) =>{
        console.log(err)
        console.log(typeof err);
        console.log(err === "500");
        console.log(err === 500);
        this.alertService.presentAlert('Erro '+ err.status, `${err.error.detail}`);

        if(err === '500'){

        }
        this.hideLoading();
        //this.invalidUser = true;
        //this.isLoading = false;
      },
      complete: () =>{
        //this.isLoading = false;
      }
  })
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


  navigateToForgotPass() {
    this.router.navigate(['account/forgot']);
  }
}
