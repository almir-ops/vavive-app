import { Component, OnInit, ViewChild } from '@angular/core';
import { FormGroup, FormBuilder, Validators, AbstractControl } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { AuthService } from '../auth.service';
import { VerificationService } from 'src/app/shared/verifications/verification-service.service';
import { Storage } from '@ionic/storage-angular';
import { Preferences } from '@capacitor/preferences';
import { IonModal } from '@ionic/angular';
import { ViacepService } from 'src/app/shared/services/viacep/viacep.service';
import { MaskitoElementPredicate, MaskitoOptions } from '@maskito/core';
import { ClientesService } from 'src/app/shared/services/clientes/clientes.service';
import { EnderecosService } from 'src/app/shared/services/enderecos/enderecos.service';
import { AlertComponent } from 'src/app/shared/components/alert/alert.component';
import { FranquiasService } from 'src/app/shared/services/franquias/franquias.service';
import { environment } from 'src/environments/environment';

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
  user: any;
  @ViewChild('modalNovoEndereco') modalNovoEndereco!: IonModal;
  @ViewChild('modalEditEndereco') modalEditEndereco!: IonModal;
  @ViewChild('modalDeleteEndereco') modalDeleteEndereco!: IonModal;
  @ViewChild('modalErroEndereco') modalErroEndereco!: IonModal;
  @ViewChild('modalFranquiaChange') modalFranquiaChange!: IonModal;

  isModalOpen = false;
  cep: string = '';
  enderecoEncontrado = false;
  endereco: any = {
    ID: '',
    rua: '',
    bairro: '',
    cidade: '',
    estado: '',
    cep: '',
    numero: '',
    complemento: '',
  };
  cepMask: MaskitoOptions = {
    mask: [
      /\d/, /\d/, /\d/, /\d/, /\d/, '-', /\d/, /\d/, /\d/
    ]
  };
  public readonly predicate: MaskitoElementPredicate = (element) =>
  (element as HTMLIonInputElement).getInputElement();
  @ViewChild('alertComponent') alertComponent!: AlertComponent;
  regions: any[] = [];
  currentFranquia:any;
  franquiaEncontrada:any;

  constructor(
    private formBuilder: FormBuilder,
    private router: Router,
    private route: ActivatedRoute,
    private authService: AuthService,
    private verification: VerificationService,
    private storage: Storage,
    private viacepService: ViacepService,
    private clienteService: ClientesService,
    private enderecoService: EnderecosService,
    private franquiasService: FranquiasService

  ) { }

  ngOnInit() {
    this.createForm();
    this.getInfoUser();
    this.franquiasService.getFranquias().subscribe(data => {
      this.regions = data;
      console.log(this.regions);
    });
    console.log(this.getFranquia());

  }

  getInfoUser(){
    this.getUserSecurely().then(user => {
      if (user) {
        console.log('Usuário recuperado:', user);
        this.user = user;
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

   updateClient(){

   }

  onWillDismiss() {
    this.resetForm();
  }

  openModalEndereco(){
    this.modalNovoEndereco.present();
  }

  openModalEditEndereco(endereco:any){
    this.enderecoEncontrado = true;
    this.endereco = endereco;
    this.cep = endereco.cep
    this.modalEditEndereco.present();
  }

  openModalDeleteEndereco(endereco:any){
    this.enderecoEncontrado = true;
    this.endereco = endereco;
    this.cep = endereco.cep
    this.modalDeleteEndereco.present();
  }


  buscarCep() {
    console.log(this.cep);

    if (this.cep.length === 9) { // Validação básica para CEP
      this.viacepService.buscarEndereco(this.cep.replace('-', '')).subscribe({
        next: (endereco) => {
          if (!endereco.erro) {
            // Se o CEP for encontrado, preencher os campos com os valores recebidos
            this.endereco.rua = endereco.logradouro;
            this.endereco.bairro = endereco.bairro;
            this.endereco.cidade = endereco.localidade;
            this.endereco.estado = endereco.uf;
            this.endereco.cep = endereco.cep;
            this.enderecoEncontrado = true;
            let franquia:any

             // Se o estado for DF, buscar pela franquia correspondente ao estado
             if (endereco.uf === 'DF') {
              // Busca pela franquia correspondente ao estado DF
              franquia = this.regions.find((r: any) => r.estado.toLowerCase() === 'df');
            } else {
              // Comparar a localidade do endereço com os bairros da lista de franquias
              franquia = this.regions.find((r: any) =>
                r.bairros.some((bairroObj: any) =>
                  (typeof bairroObj === 'string' ? bairroObj.toLowerCase() : bairroObj.nome.toLowerCase()) === endereco.localidade.toLowerCase()
                )
              );
            }

            // Se não encontrou uma franquia e o estado é SP ou RJ, usa a franquia "Matriz"
            if (!franquia && (endereco.uf === 'SP' || endereco.uf === 'RJ')) {
              franquia = this.regions.find((r: any) => r.nome.toLowerCase() === 'matriz');
            }

            console.log(this.currentFranquia, franquia.nome);
            this.franquiaEncontrada = franquia
            if(this.currentFranquia !== franquia.nome){
              this.openMoralChangeFranquia()
              return
            }


          } else {
            // Caso não encontre o CEP
            console.error('CEP não encontrado.');
          }
        },
        error: (err) => {
          console.error('Erro ao buscar o CEP:', err);
        }
      });
    }else{
      this.enderecoEncontrado = false;
    }
  }

  async getFranquia(){
    const franquia = await this.storage.get('franquia');
    this.currentFranquia = franquia
  }

  isFormValid() {
    // Verifica se o CEP foi buscado e se o número foi preenchido
    return this.enderecoEncontrado && this.endereco.numero;
  }

  salvarEndereco() {
    // Verificar se o endereço está preenchido corretamente
    if (this.isFormValid()) {
      // Adicionar o novo endereço à lista de endereços do usuário
      if (!this.user.enderecos) {
        this.user.enderecos = [];
      }

      // Adiciona o novo endereço à lista de endereços do usuário
      this.user.enderecos.push({
        rua: this.endereco.rua,
        numero: this.endereco.numero,
        bairro: this.endereco.bairro,
        cidade: this.endereco.cidade,
        estado: this.endereco.estado,
        cep: this.endereco.cep,
        complemento: this.endereco.complemento,
        zona: this.endereco.zona || '', // Verifique outros campos como zona e latitude/longitude, se necessário
        latitude: this.endereco.latitude || '',
        longitude: this.endereco.longitude || ''
      });

      console.log('Endereço salvo:', this.endereco);
      console.log('Lista de endereços atualizada:', this.user.enderecos);
      this.clienteService.updateClient(this.user).subscribe({
        next: (response:any) => {
          console.log('Cliente atualizado:', response);
          Preferences.set({
            key: 'user_data',
            value: JSON.stringify(response.item)
          })
          this.getInfoUser()
          this.modalNovoEndereco.dismiss();
        },
        error: (err:any) => {
          console.error('Erro ao atualizar o cliente:', err);
        }
      })
      // Fechar o modal
    } else {
      console.log('O formulário de endereço está incompleto.');
    }
  }

  updateEndereco(){
    this.enderecoService.putEndereco(this.endereco).subscribe({
      next: (data) => {
        this.resetForm();
        this.enderecoEncontrado = false;
        this.modalEditEndereco.dismiss();
        console.log('Endereco atualizado:', data);
      },
      error: (err) => {
        console.error('Erro ao atualizar o cliente:', err);
      }
    })
  }

  deleteEndereco(){
    this.enderecoService.deleteEndereco(this.endereco).subscribe({
      next: (data) => {
        this.resetForm();
        this.enderecoEncontrado = false;
        this.modalEditEndereco.dismiss();
      },
      error: (err) => {
        console.error('Erro ao atualizar o cliente:', err);
        this.modalErroEndereco.present()
      }
    })
  }

  resetForm() {
    this.cep = '';
    this.enderecoEncontrado = false;
    this.endereco = {
      rua: '',
      bairro: '',
      cidade: '',
      estado: '',
      cep: '',
      numero: '',
      complemento: ''
    };
  }

  openMoralChangeFranquia(){
    this.modalFranquiaChange.present();
  }

  async preencherManual(){
    await this.storage.set('endereco', this.endereco);
    await this.storage.set('front_url', this.franquiaEncontrada.url_front);
    await this.storage.set('api_url', this.franquiaEncontrada.url);
    await this.storage.set('franquia', this.franquiaEncontrada.nome);
    await this.storage.set('current_cep', this.endereco.cep);
    console.log(this.endereco);

    console.log(this.franquiaEncontrada.url);
    console.log(environment.baseUrl);


    this.logout();
    this.navegate('account/sign')
  }

  openExternalLink(url: string): void {
    window.open(url, '_blank');
  }

}
