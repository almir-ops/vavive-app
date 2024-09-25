import { Component, OnInit } from '@angular/core';
import { FormGroup, FormBuilder, Validators, AbstractControl } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { AuthService } from '../auth.service';
import { VerificationService } from 'src/app/shared/verifications/verification-service.service';
import { Storage } from '@ionic/storage-angular';
import { Preferences } from '@capacitor/preferences';

@Component({
  selector: 'app-profile',
  templateUrl: './profile.component.html',
  styleUrls: ['./profile.component.scss'],
})
export class ProfileComponent  implements OnInit {


  token:any;
  screnn: string = 'profile';
  formRegister!: FormGroup;
  hiddenPassword: boolean = false;
  type!:string;
  cpfInvalido = false;
  cnpjInvalido = false;

  constructor(
    private formBuilder: FormBuilder,
    private router: Router,
    private route: ActivatedRoute,
    private authService: AuthService,
    private verification: VerificationService,
    private storage: Storage,
  ) { }

  ngOnInit() {
    this.createForm();
    this.getUserSecurely().then(user => {
      if (user) {
        console.log('Usuário recuperado:', user);
        this.setFormValues(user)
      } else {
        console.log('Nenhum usuário encontrado.');
      }
    }).catch(error => {
      console.error('Erro ao recuperar o usuário:', error);
    });
  }

  async getUserSecurely() {
    try {
      const { value: user } = await Preferences.get({ key: 'user_data' });
      return user ? JSON.parse(user) : null; // Converte de volta para objeto, se existir
    } catch (error) {
      console.error('Error retrieving user data securely:', error);
      return null;
    }
  }

  createForm(){
    this.formRegister = this.formBuilder.group({
      username:['', Validators.required],
      password:['', Validators.required],
      nome:[],
      celular:[],
      cpf:[],
      email:[]
    })
  }

  setFormValues(values: any) {
    this.formRegister.setValue({
      username: values.username || '',
      password: values.password || '',
      nome: values.nome || '',
      celular: values.celular || '',
      cpf: values.cpf || '',
      email: values.email || ''
    });
  }

  get formRegisterControl(): { [key: string]: AbstractControl } {
    return this.formRegister.controls;
  }

  viewPassword() {
    this.hiddenPassword = !this.hiddenPassword;
  }

  login(){

  }

  navegate(rota:string){
    this.router.navigate([rota]);
  }

  segmentChanged(event: any) {
    this.screnn = event.detail.value;
  }

  verificationCPF(cpf:any){
    const CPF = (cpf.target as HTMLInputElement).value;
    if(CPF.replace(/\.|-/g, '').length >= 11){
      if(!this.verification.validateCPF(CPF.replace(/\.|-/g, ''))){
        this.cpfInvalido = true;
      }else{
        this.cpfInvalido = false;
      }
    }
  }

   verificationCNPJ(cnpj:any){
    const CNPJ = (cnpj.target as HTMLInputElement).value;
    if(CNPJ.replace(/\.|-/g, '').length >= 14){
      if(!this.verification.validateCNPJ(CNPJ.replace(/\.|-/g, ''))){
        this.cnpjInvalido = true;
      }else{
        this.cnpjInvalido = false;
      }
    }
   }

   logout(){
    this.authService.logout();
   }
}
