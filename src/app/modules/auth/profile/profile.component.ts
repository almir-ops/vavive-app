import { Component, OnInit, ViewChild } from '@angular/core';
import { FormGroup, FormBuilder, Validators, AbstractControl } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { AuthService } from '../auth.service';
import { VerificationService } from 'src/app/shared/verifications/verification-service.service';
import { Storage } from '@ionic/storage-angular';
import { Preferences } from '@capacitor/preferences';
import { IonModal, AlertController } from '@ionic/angular';
import { ViacepService } from 'src/app/shared/services/viacep/viacep.service';
import { MaskitoElementPredicate, MaskitoOptions } from '@maskito/core';
import { ClientesService } from 'src/app/shared/services/clientes/clientes.service';
import { EnderecosService } from 'src/app/shared/services/enderecos/enderecos.service';
import { AlertComponent } from 'src/app/shared/components/alert/alert.component';
import { FranquiasService } from 'src/app/shared/services/franquias/franquias.service';
import { environment } from 'src/environments/environment';
import { AlertService } from 'src/app/shared/services/alert.service';
import { uCliente } from 'src/app/shared/interfaces/uCliente';

@Component({
  selector: 'app-profile',
  templateUrl: './profile.component.html',
  styleUrls: ['./profile.component.scss'],
})
export class ProfileComponent  implements OnInit {


  token:any;
  screen: string = 'profile';
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
  @ViewChild('modalDeletedAccount') modalDeletedAccount!: IonModal;

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
  @ViewChild('modalFranquias', { static: false }) modalFranquias!: IonModal;
  regionsCurrent: any[] = [];

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
    private franquiasService: FranquiasService,
    private alertService: AlertService,

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
      ID:['', Validators.required],
      password:['', Validators.required],
      nome:['', Validators.required],
      celular:['', Validators.required],
      cpf:['', Validators.required],
      email:['', Validators.required]
    })
  }

  setFormValues(values: any) {
    this.formRegister.setValue({
      ID: values.ID,
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
    this.screen = event.detail.value;
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
    console.log(this.formRegister.getRawValue());
    const cliente: uCliente = this.formRegister.getRawValue();
    this.clienteService.updateClient(cliente).subscribe({
      next:(value:any) => {
        console.log(value);
        Preferences.set({
          key: 'user_data',
          value: JSON.stringify(value.item)
        })
      },
      error:(err:any) => {
        console.log(err);
        this.alertService.presentAlert('Atenção ', `Erro ao atualizar cliente`);

      },
    })
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

  openModalDeleteEndereco(endereco:any, index:any){
    if(index > 0){
      this.enderecoEncontrado = true;
      this.endereco = endereco;
      this.cep = endereco.cep
      this.modalDeleteEndereco.present();
    }else{
      this.alertService.presentAlert('Atenção ', `Adicione um novo endereço para excluir o principal.`);
    }
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

  searchCep() {
    let cep = this.cep;

    // Remove tudo que não for dígito
    cep = cep.replace(/\D/g, '');
    console.log(cep);

    if (cep.length === 8) {
    // Chama o serviço ViaCEP para obter os dados do endereço
    this.viacepService.buscarEndereco(cep).subscribe(
      async (endereco: any) => {
        if (endereco && !endereco.erro) {
          console.log('Endereço encontrado:', endereco);
          console.log(this.regions);

          let region: any;

          // Primeiro, busca pela cidade na lista de franquias
          region = this.regions.find((r: any) =>
            r.cidade.toLowerCase() === endereco.localidade.toLowerCase()
          );

          if (region) {
            console.log('Cidade encontrada na franquia:', region);
          } else {
            console.log('Cidade não encontrada. Comparando com:', endereco.localidade);
          }

          // Se não encontrou a cidade e o estado é DF, buscar pela franquia correspondente ao estado
          if (!region && endereco.uf === 'DF') {
            region = this.regions.find((r: any) => r.estado.toLowerCase() === 'df');
            if (region) {
              console.log('Estado DF encontrado na franquia:', region);
            } else {
              console.log('Estado DF não encontrado. Comparando com:', endereco.uf);
            }
          }

        // Verificar se o CEP está dentro da faixa de valores
        if (!region) {
          const cepNumber = parseInt(cep.replace('-', ''), 10); // Remove o hífen e converte para número
          console.log('Verificando faixa de CEP:', cepNumber);

          region = this.regions.find((r: any) => {
            const startCep = parseInt(r.latitude.replace('-', ''), 10); // Remove o hífen e converte
            const endCep = parseInt(r.longitude.replace('-', ''), 10);  // Remove o hífen e converte

            console.log(`Comparando CEP ${cepNumber} com faixa: ${startCep} - ${endCep}`);
            return cepNumber >= startCep && cepNumber <= endCep;
          });

          if (region) {
            console.log('CEP encontrado na faixa da franquia:', region);
          } else {
            console.log('CEP não encontrado na faixa. Comparando:', cepNumber);
          }
        }


          // Se ainda não encontrou, verificar se o CEP está dentro da faixa de valores
          if (!region) {
            const cepNumber = parseInt(cep, 10); // Certifique-se de que o CEP é tratado como número
            console.log('Verificando faixa de CEP:', cepNumber);

            region = this.regions.find((r: any) =>
              cepNumber >= parseInt(r.latitude, 10) && cepNumber <= parseInt(r.longitude, 10)
            );

            if (region) {
              console.log('CEP encontrado na faixa da franquia:', region);
            } else {
              console.log('CEP não encontrado na faixa. Comparando:', cepNumber);
            }
          }

          // Se não encontrou uma franquia e o estado é SP ou RJ, usa a franquia "Matriz"
          if (!region && (endereco.uf === 'SP')) {
            //region = this.regions.find((r: any) => r.nome.toLowerCase() === 'matriz');
            this.modalFranquias.present();
            this.regionsCurrent = this.regions.reduce((unique: any[], region: any) => {
              if (!unique.some((item) => item.nome === region.nome)) {
                unique.push(region);
              }
              return unique;
            }, []);
          }

          if (this.currentFranquia !== region.nome) {
            this.franquiaEncontrada = region
            this.openMoralChangeFranquia()
          } else {
            this.endereco.rua = endereco.logradouro;
            this.endereco.bairro = endereco.bairro;
            this.endereco.cidade = endereco.localidade;
            this.endereco.estado = endereco.uf;
            this.endereco.cep = endereco.cep;
            this.enderecoEncontrado = true;
          }

        } else {
          console.log('CEP inválido ou não encontrado.');
        }
      },
      (error: any) => {
        console.error('Erro ao buscar o CEP:', error);
      }
    );



    } else {
      console.log('CEP incompleto ou inválido.');
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
    this.modalNovoEndereco.dismiss();
    this.modalFranquiaChange.dismiss();
    this.logout();
    this.navegate('account/sign')
  }

  openExternalLink(url: string): void {
    window.open(url, '_blank');
  }

  deleteAccount(){
    const cliente: uCliente = this.formRegister.getRawValue();

    this.clienteService.deleteClient(cliente).subscribe({
      next: (data) => {
        this.modalDeletedAccount.dismiss();
        this.logout();
      },
      error: (err) => {
        console.error('Erro ao deletar a conta:', err);
      }
    })
  }

  selectFranquia(region: any){

    this.storage.set('endereco', region);
    this.storage.set('front_url', region.url_front);
    this.storage.set('api_url', region.url);
    this.storage.set('franquia', region.nome);
    this.storage.set('email_franquia', region.email_contato);
    this.storage.set('contato_franquia', region.numero_contato);
    this.authService.logout();
    this.modalNovoEndereco.dismiss();
    this.modalFranquias.dismiss();

    this.router.navigate(['/start']);
  }
}
