import { Component, OnInit, ViewChild } from '@angular/core';
import {
  AbstractControl,
  FormArray,
  FormBuilder,
  FormControl,
  FormGroup,
  ValidatorFn,
  Validators,
} from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { MaskitoOptions, MaskitoElementPredicate } from '@maskito/core';
import { LoadingComponent } from 'src/app/shared/components/loading/loading.component';
import { uSetups } from 'src/app/shared/interfaces/uSetups';
import { VerificationService } from 'src/app/shared/verifications/verification-service.service';
import { AuthService } from '../auth.service';
import { Storage } from '@ionic/storage-angular';
import { Observable } from 'rxjs';
import { AlertService } from 'src/app/shared/services/alert.service';

@Component({
  selector: 'app-register',
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.scss'],
})
export class RegisterComponent implements OnInit {
  styleBorderUser: any = '';
  formRegister!: FormGroup;
  hiddenPassword: boolean = false;
  type!: string;
  cpfMaskOptions: MaskitoOptions = {
    mask: [
      /\d/,
      /\d/,
      /\d/,
      '.',
      /\d/,
      /\d/,
      /\d/,
      '.',
      /\d/,
      /\d/,
      /\d/,
      '-',
      /\d/,
      /\d/,
    ],
  };

  phoneMaskOptions: MaskitoOptions = {
    mask: [
      '(',
      /\d/,
      /\d/,
      ')',
      ' ',
      /[1-9]/, // O primeiro dígito deve ser de 1 a 9 (para telefone móvel)
      ' ',
      /\d/,
      /\d/,
      /\d/,
      /\d/,
      '-',
      /\d/,
      /\d/,
      /\d/,
      /\d/,
    ],
  };

  cepMask: MaskitoOptions = {
    mask: [/\d/, /\d/, /\d/, /\d/, /\d/, '-', /\d/, /\d/, /\d/],
  };
  cpfInvalido = false;
  cnpjInvalido = false;
  frontUrl: any;
  endereco: any;
  schemaFranquia: any;
  api_url: any;

  public readonly predicate: MaskitoElementPredicate = (element) =>
    (element as HTMLIonInputElement).getInputElement();

  @ViewChild('loadingComponent') loadingComponent!: LoadingComponent;
  setups: uSetups[] = [
    {
      label: 'APP-vavive-matriz',
      url: 'https://vavive-go-production.up.railway.app/api/v1/',
      cidade: 'SP',
    },
  ];
  passwordErrors: any = {
    minLength: false,
    specialChar: false,
    number: false,
    upperLower: false,
  };

  constructor(
    private formBuilder: FormBuilder,
    private router: Router,
    private route: ActivatedRoute,
    private verification: VerificationService,
    private authService: AuthService,
    private storage: Storage,
    private alertService: AlertService
  ) {}

  ngOnInit() {
    this.getFrontUrlFromStorage();
    this.route.queryParams.subscribe((params) => {
      this.type = params['tipo'];
      console.log(this.type); // 'Cliente', 'Empresa' ou 'Profissional'
    });
    this.createForm();
    this.addEndereco();
  }

  createForm() {
    this.formRegister = this.formBuilder.group({
      username: [''],
      password: ['', [Validators.required, this.passwordValidator.bind(this)]],
      nome: ['', Validators.required],
      celular: ['', [Validators.required, Validators.minLength(16)]],
      cpf: [
        '',
        [
          Validators.required,
          Validators.minLength(14),
          this.cpfCnpjValidator(this.type),
        ],
      ],
      cnpj: ['', [Validators.minLength(18), this.cpfCnpjValidator(this.type)]],
      email: ['', [Validators.required, Validators.email]],
      enderecos: this.formBuilder.array([]),
      cep: [''],
      source: [{ value: this.frontUrl }],
    });
    this.formRegister
      .get('password')
      ?.setValidators([Validators.required, this.passwordValidator.bind(this)]);

    this.formRegister
      .get('cpf')
      ?.setValidators(this.cpfCnpjValidator(this.type));
    this.formRegister
      .get('cnpj')
      ?.setValidators(this.cpfCnpjValidator(this.type));
  }

  passwordValidator(
    control: AbstractControl
  ): { [key: string]: boolean } | null {
    const value = control.value || '';

    // Validações
    this.passwordErrors.minLength = value.length >= 6;
    this.passwordErrors.specialChar = /[!@#$%^&*(),.?":{}|<>]/.test(value);
    this.passwordErrors.number = /\d/.test(value);
    this.passwordErrors.upperLower = /[a-z]/.test(value) && /[A-Z]/.test(value);

    // Verifica se é válido
    const isValid =
      this.passwordErrors.minLength &&
      this.passwordErrors.specialChar &&
      this.passwordErrors.number &&
      this.passwordErrors.upperLower;

    // Retorna null se for válido, ou um objeto com o erro se não for
    return isValid ? null : { passwordInvalid: true };
  }

  get formRegisterControl(): { [key: string]: AbstractControl } {
    return this.formRegister.controls;
  }
  get enderecos(): FormArray {
    return this.formRegister.get('enderecos') as FormArray;
  }

  async getFrontUrlFromStorage() {
    this.frontUrl = await this.storage.get('front_url');
    this.endereco = await this.storage.get('endereco');
    this.schemaFranquia = await this.storage.get('schema');
    this.api_url = await this.storage.get('api_url');
    if (this.frontUrl && this.endereco) {
      this.enderecos.at(0).get('estado')?.patchValue(this.endereco.uf);
      this.formRegister.patchValue({
        source: this.frontUrl,
      });
    }
  }

  addEndereco() {
    const enderecoForm = this.formBuilder.group({
      rua: [''],
      cep: [''],
      numero: [''],
      bairro: [''],
      referencia: [''],
      cidade: [''],
      estado: [''],
      pais: [''],
      zona: [''],
      complemento: [''],
      latitude: [''],
      longitude: [''],
    });

    this.enderecos.push(enderecoForm);
  }
  showAlertUser() {
    const { username } = this.formRegister.getRawValue();
  }

  enableBtnLogin() {}

  viewPassword() {
    this.hiddenPassword = !this.hiddenPassword;
  }

  register() {
    const source = this.formRegister.controls['source'].value;
    let celular = this.formRegister.controls['celular'].value;

    // Remove todos os caracteres que não são números do campo celular
    celular = celular.replace(/\D/g, '');

    // Se o tipo for 'Empresa', atribui o CNPJ ao campo de CPF
    if (this.type === 'Empresa') {
      this.formRegister.controls['cpf'].setValue(
        this.formRegister.controls['cnpj'].value
      );
    }

    const request = {
      username: this.formRegister.controls['username'].value,
      password: this.formRegister.controls['password'].value,
      nome: this.formRegister.controls['nome'].value,
      celular: celular,
      telefone: celular,
      cpf_cnpj: this.formRegister.controls['cpf'].value
        ? this.formRegister.controls['cpf'].value.replace(/\D/g, '')
        : this.formRegister.controls['cpf'].value.replace(/\D/g, ''),
      cnpj: this.formRegister.controls['cnpj'].value
        ? this.formRegister.controls['cnpj'].value.replace(/\D/g, '')
        : '',
      email: this.formRegister.controls['email'].value,
      enderecos: null,
      cep: this.formRegister.controls['cep'].value,
      source: source,
      origem_cliente: 'APP',
      franquia: this.schemaFranquia,
      role: 3,
      source_api: this.api_url,
    };

    console.log('Request object:', request); // Exibe o objeto para verificação

    // Verificação de validação
    if (this.formRegister.valid) {
      // Chama o serviço de registro utilizando o objeto `request` criado acima
      this.authService.registerNewUser(request, 'clientes').subscribe({
        next: (value: any) => {
          console.log(value);
          this.alertService.presentAlert(
            'Aviso',
            'Conta criada com sucesso, faça login novamente para prosseguir.',
            () => {
              this.navegate('/account/sign');
            }
          );
        },
        error: (err: any) => {
          console.log(err);
          this.alertService.presentAlert('Atenção', `${err.error.detail}`);
        },
      });
    } else {
      // Exibe no console quais campos estão inválidos
      Object.keys(this.formRegister.controls).forEach((field) => {
        const control = this.formRegister.get(field);
        if (control && control.invalid) {
          console.log(`Campo inválido: ${field}, Erros:`, control.errors);
        }
      });

      // Mensagem de alerta para o usuário
      this.alertService.presentAlert(
        'Erro',
        'Preencha todos os campos corretamente.'
      );
    }
  }

  navegate(rota: string) {
    this.router.navigate([rota]);
  }

  cpfCnpjValidator(type: string): ValidatorFn {
    return (control: AbstractControl): { [key: string]: any } | null => {
      const value = control.value;
      if (type === 'Cliente') {
        // Validação de CPF
        if (value && value.replace(/\.|-/g, '').length >= 11) {
          return this.verification.validateCPF(value.replace(/\.|-/g, ''))
            ? null
            : { invalidCPF: true };
        }
      } else if (type === 'Empresa') {
        // Validação de CNPJ
        if (value && value.replace(/\.|-/g, '').length >= 14) {
          return this.verification.validateCNPJ(value.replace(/\.|-/g, ''))
            ? null
            : { invalidCNPJ: true };
        }
      }
      return null;
    };
  }

  verificationCPF(cpf: any) {
    const CPF = (cpf.target as HTMLInputElement).value;
    if (CPF.replace(/\.|-/g, '').length >= 11) {
      if (!this.verification.validateCPF(CPF.replace(/\.|-/g, ''))) {
        this.cpfInvalido = true;
      } else {
        this.cpfInvalido = false;
      }
    }
  }

  verificationCNPJ(cnpj: any) {
    const CNPJ = (cnpj.target as HTMLInputElement).value;
    if (CNPJ.replace(/\.|-/g, '').length >= 14) {
      if (!this.verification.validateCNPJ(CNPJ.replace(/\.|-/g, ''))) {
        this.cnpjInvalido = true;
      } else {
        this.cnpjInvalido = false;
      }
    }
  }

  showLoading() {
    this.loadingComponent.createLoading();
  }

  hideLoading() {
    this.loadingComponent.dismissLoading();
  }
}
