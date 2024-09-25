import { Component, OnInit, ViewChild } from '@angular/core';
import { FormGroup, FormBuilder, Validators, AbstractControl } from '@angular/forms';
import { Router } from '@angular/router';
import { AlertComponent } from 'src/app/shared/components/alert/alert.component';
import { LoadingComponent } from 'src/app/shared/components/loading/loading.component';
import { IUser } from 'src/app/shared/interfaces/uUser';
import { AuthService } from '../auth.service';

@Component({
  selector: 'app-forgot-password',
  templateUrl: './forgot-password.component.html',
  styleUrls: ['./forgot-password.component.scss'],
})
export class ForgotPasswordComponent  implements OnInit {

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
    private authService: AuthService

  ) { }

  ngOnInit() {
    this.createForm();
  }

  createForm(){
    this.formLogin = this.formBuilder.group({
      email:['', Validators.required],
      password:['', Validators.required]
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
      password: this.formLogin.controls['password'].value
    };
    this.showLoading();

    this.authService.login(user,this.paramUser).subscribe({
      next: (response:any) => {
        console.log(response);
        //this.router.navigate(['start']);
        this.alertComponent.message = 'Login efetuado com sucesso!';
        this.alertComponent.presentAlert();
        this.hideLoading();
      },error: (err) =>{
        console.log(err);
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

  navigateToAccountSign() {
    this.router.navigate(['account/sign']);
  }
}
