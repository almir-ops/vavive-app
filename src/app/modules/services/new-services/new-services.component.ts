import { Component, OnInit, ViewChild } from '@angular/core';
import { AbstractControl, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { AlertController, IonicSlides, IonModal, PickerController } from '@ionic/angular';
import * as moment from 'moment';
import { Preferences } from '@capacitor/preferences';
import { Storage } from '@ionic/storage-angular';
import { ServicosService } from 'src/app/shared/services/servicos/servicos.service';
import { uPlano } from 'src/app/shared/interfaces/uPlano';
import { ViacepService } from 'src/app/shared/services/viacep/viacep.service';
import { Router } from '@angular/router';
import { ClientesService } from 'src/app/shared/services/clientes/clientes.service';
import { EnderecosService } from 'src/app/shared/services/enderecos/enderecos.service';
import { AtendimentosService } from 'src/app/shared/services/atendimentos/atendimentos.service';
import { LoadingComponent } from 'src/app/shared/components/loading/loading.component';
import { AnimationOptions } from 'ngx-lottie';
import { AnimationItem } from 'lottie-web';

@Component({
  selector: 'app-new-services',
  templateUrl: './new-services.component.html',
  styleUrls: ['./new-services.component.scss'],
})
export class NewServicesComponent  implements OnInit {


  formAtendimento!: FormGroup;
  hourSelected = 4;
  cepSelected = "";
  swiperModules = [IonicSlides];
  selectedDate = '';
  currentClient: any;
  currentEndereco: any;
  isModalOpen = false;
  minDate!: string;
  minDateFim!: string;
  timeOptions: string[] = [];
  selectedTime!: string;
  hourInit!: string;

  @ViewChild('modalDateInit', { static: false }) modalDateInit!: IonModal;
  @ViewChild('modalDateFim', { static: false }) modalDateFim!: IonModal;
  @ViewChild('modalMissing', { static: false }) modalMissing!: IonModal;
  @ViewChild('modalConfirm', { static: false }) modalConfirm!: IonModal;

  services = [
    { ID: 1, icon:'./assets/icons/home.svg' ,iconwhite:'./assets/icons/home-white.svg' , Precos: [], nome: 'Limpeza residencial', descricao: 'Limpeza completa de sua casa, cuidando de todos os ambientes.' },
    { ID: 2, icon:'./assets/icons/home.svg' ,iconwhite:'./assets/icons/home-white.svg' , Precos: [], nome: 'Passar roupa', descricao: 'Roupas passadas com cuidado, prontas para qualquer ocasião.' },
    { ID: 3, icon:'./assets/icons/home.svg' ,iconwhite:'./assets/icons/home-white.svg' , Precos: [], nome: 'Cozinhar', descricao: 'Preparo de refeições caseiras, sem preocupações na cozinha.' },
    { ID: 4, icon:'./assets/icons/home.svg' ,iconwhite:'./assets/icons/home-white.svg' , Precos: [], nome: 'Baba', descricao: 'Cuidado infantil responsável, com segurança e entretenimento.' }
  ];

  planos:uPlano [] = [
    { id: 1, plano: 'avulso', name: 'Avulso' },
    { id: 2, plano: 'quinzenal', name: 'Quinzenal' },
    { id: 3, plano: 'semanal', name: 'Semanal' },
    { id: 4, plano: '2x', name: '2x na semana' },
    { id: 5, plano: '3x', name: '3x na semana' },
    { id: 6, plano: '4x', name: '4x na semana' },
    { id: 7, plano: '5x', name: '5x na semana' },
    { id: 8, plano: '6x', name: '6x na semana' },
    { id: 9, plano: '7x', name: '7x na semana' }
  ];

  nextFiveDays: any[] = [];
  nextFiveDaysFinal: any[] = [];
  selectedServiceId: number | null = null;
  selectedPlano: uPlano = { id: 1, plano: 'avulso', name: 'Avulso' } ;
  selectedDateFim = '';
  indexServiceSelected!: number;
  msgProfissional: any;
  missingFields: string[] = [];
  preco: any;
  @ViewChild('loadingComponent') loadingComponent!: LoadingComponent;

  animation = false;
  options: AnimationOptions = {
    path: 'assets/lotties/animation_confirmed.json',  // Caminho para o arquivo da animação
    loop: false,  // Desativa o loop para que a animação aconteça apenas uma vez
    autoplay: true  // A animação começa automaticamente quando renderizada
  };

      // Callback que é chamado quando a animação é criada
  animationCreated(animationItem: AnimationItem): void {

    // O evento "complete" pode ser usado para ações após o término da animação
    animationItem.addEventListener('complete', () => {
    });
  }
  constructor(
    private formBuilder: FormBuilder,
    private pickerCtrl: PickerController,
    private storage: Storage,
    private servicos: ServicosService,
    private viaCep: ViacepService,
    private router: Router,
    private clienteService: ClientesService,
    private enderecoService: EnderecosService,
    private atendimentoService: AtendimentosService
  ) { }

  ngOnInit() {
    moment.locale('pt-br');
    this.initializeForm();
    this.loadNextFiveDays();
    this.loadNextFiveDaysFinal();
    this.setMinDate();
    this.generateTimeOptions();
    this.loadUserData();
    this.servicos.getServicos().subscribe({
      next: (data) => {

        this.services = this.services.map(service => {
          const updatedService = data.items.find((apiService: any) => apiService.ID === service.ID);
          return updatedService ? { ...service, Precos: updatedService.Precos } : service;
        });

        console.log('Lista de serviços atualizada:', this.services);
      },
      error: (err) => {
        console.error('Erro ao buscar dados de serviços:', err);
      }
    });
  }

  initializeForm() {
    const plano_id = moment().format('DDMMYYYYHHmmssSSS');
    this.formAtendimento = this.formBuilder.group({
      nome: [{ value: '', disabled: true }, Validators.required],
      CPF: [{ value: '', disabled: true }, Validators.required],
      endereco: this.formBuilder.group({
        cep: [{ value: '', disabled: true }, Validators.required],
        rua:[{ value: '', disabled: true }, Validators.required],
        bairro: [{ value: '', disabled: true }, Validators.required],
        cidade:[{ value: '', disabled: true }, Validators.required],
        estado:[{ value: '', disabled: true }, Validators.required],
        pais:[{ value: '', disabled: true }, Validators.required],
        complemento:[{ value: '', disabled: false }],
        zona:[{ value: '', disabled: true }],
        numero:[{ value: '', disabled: false }, Validators.required]

      }),
      cliente:this.formBuilder.group({
        email: [{ value: '', disabled: true }, Validators.required],
      }),
      datas: [],
      telefone: [{ value: '', disabled: true }, Validators.required],
      data_inicio: [],
      data_fim: [],
      hora_de_entrada: ['', Validators.required],
      horaFinal: [],
      duracao: ['', Validators.required],
      observacoes_de_servicos: [''],
      observacoes_de_prestador: [''],
      usuario: ['Cliente'],
      nome_vendedor: ['Cliente'],
      servicos: this.formBuilder.array([]),
      status_atendimento: ['Pendente'],
      status_pagamento: ['Pagamento pendente'],
      forma_pagamento: ['', Validators.required],
      desconto: [],
      acrestimo: [],
      valor_servicos: [0.00],
      valor_total: [0.00],
      preferencias_de_profissionais: this.formBuilder.array([]),
      profissional: this.formBuilder.array([]),
      repeticoes: [''],
      pagamento_antecipado: ['N', Validators.required],
      observacaovalor: [],
      plano: ['avulso', Validators.required],
      plano_id: [plano_id],
      datas_selecionadas: []
    });
  }

  async loadUserData() {
    try {
      const user = await this.getUserSecurely();
      console.log(user);

      if (user) {
        this.currentClient = user;
        this.currentEndereco = user.enderecos[0];
        console.log(this.currentClient);

        this.updateClientData();
        if(!this.currentEndereco.cep){
          this.getCurrentCep();
        }
      } else {
        console.log('Nenhum usuário encontrado.');
      }
    } catch (error) {
      console.error('Erro ao recuperar o usuário:', error);
    }
  }

  async getCurrentCep() {
    try {
      const cep = await this.storage.get('current_cep');
      if (cep) {
        this.currentEndereco.cep = cep;
        this.viaCep.buscarEndereco(cep).subscribe({
          next:(val:any)=>{
            console.log(val);
            this.currentEndereco.rua = val.logradouro;
            this.currentEndereco.bairro = val.bairro;
            this.currentEndereco.cidade = val.localidade;
            this.currentEndereco.estado = val.uf;
            this.currentEndereco.complemento = val.complemento;
            this.currentEndereco.zona = val.regiao;
            this.currentEndereco.pais = 'Brasil';
            this.updateClientData();
          }
        })
        console.log(this.currentEndereco);

      }
    } catch (error) {
      console.error('Erro ao recuperar o CEP:', error);
    }
  }

  updateClientData() {
    this.formAtendimento.patchValue({
      nome: this.currentClient.nome,
      CPF: this.currentClient.cpf,
      telefone: this.currentClient.telefone,
      endereco: this.currentEndereco,
      cliente: this.currentClient
    });
  }

  async getUserSecurely() {
    try {
      const { value: user } = await Preferences.get({ key: 'user_data' });
      return user ? JSON.parse(user) : null;
    } catch (error) {
      console.error('Erro ao recuperar os dados do usuário:', error);
      return null;
    }
  }

  loadNextFiveDays() {
    this.nextFiveDays = Array.from({ length: 5 }, (_, i) => {
      const date = moment().add(i + 1, 'days');
      return {
        dayOfWeek: this.getAbbreviation(date.format('dddd')),
        dateNumber: date.format('DD'),
        dateMonth: date.format('MM'),
        fullDate: date.format('YYYY-MM-DD')
      };
    });
  }

  loadNextFiveDaysFinal() {
    this.nextFiveDaysFinal = Array.from({ length: 5 }, (_, i) => {
      const date = moment().add(1, 'month').add(i, 'days');
      return {
        dayOfWeek: this.getAbbreviation(date.format('dddd')),
        dateNumber: date.format('DD'),
        dateMonth: date.format('MM'),
        fullDate: date.format('YYYY-MM-DD')
      };
    });
  }

  getAbbreviation(dayOfWeek: string): string {
    return dayOfWeek.substr(0, 3) + '.';
  }

  setMinDate() {
    this.minDate = moment().add(1, 'days').format('YYYY-MM-DD');
    this.minDateFim = moment().add(1, 'month').format('YYYY-MM-DD');
  }

  generateTimeOptions() {
    for (let hour = 0; hour < 24; hour++) {
      for (let minute = 0; minute < 60; minute += 30) {
        this.timeOptions.push(`${this.formatTime(hour)}:${this.formatTime(minute)}`);
      }
    }
  }

  formatTime(num: number): string {
    return num < 10 ? `0${num}` : `${num}`;
  }

  selectPlano(plano: uPlano) {
    this.selectedPlano = plano; // Atualiza o plano selecionado
  }

  // Modal-related methods
  openModal() { this.isModalOpen = true; }
  closeModal() { this.isModalOpen = false; }

  confirmModal() {
    if (this.selectedTime) {
      this.hourInit = this.selectedTime;
    }
    this.closeModal();
  }

  upHour() {
    if (this.hourSelected < 23) {
      this.hourSelected++;
      this.calculatePreco();
    }
  }

  downHour() {
    if (this.hourSelected > 1) {
      this.hourSelected--;
      this.calculatePreco();
    }
  }

  formatDate(date:string){
    return moment(date).format('DD/MM/YYYY')
  }

  onDaySelect(day: any) {
    this.selectedDate = day.fullDate;
  }

  onDayFinalSelect(day: any) {
    this.selectedDateFim = day.fullDate;
  }


  onDateSelected(event: any) {
    this.selectedDate = event.detail.value;
    console.log(this.modalDateInit);

    this.modalDateInit.dismiss();
  }

  onDateSelectedFinal(event: any) {
    this.selectedDateFim = event.detail.value;
    console.log(this.modalDateFim);

    this.modalDateFim.dismiss();
  }

  onWillDismiss() {
    if (this.selectedTime) {
      this.hourInit = this.selectedTime;
    }
  }

  onIonChange(event: any) {
    this.selectedTime = event.detail.value;
  }

  selectService(serviceId: number, indexServiceSelected: number) {
    this.indexServiceSelected = indexServiceSelected;
    this.selectedServiceId = serviceId;
    this.calculatePreco();

  }

  isServiceSelected(serviceId: number) {
    return this.selectedServiceId === serviceId;
  }

  submitNext() {
    console.log(this.isPrecoValid());

    if (!this.validateFields()) {
      return; // Se houver campos faltantes, o alerta será mostrado e o processo será interrompido
    }

    // Atualiza o cliente no formulário antes de gerar os atendimentos
    const formValues = this.formAtendimento.getRawValue();
    this.currentEndereco.numero = this.formAtendimento.get('endereco.numero')?.value;
    this.currentEndereco.complemento = this.formAtendimento.get('endereco.complemento')?.value;

    this.currentClient.enderecos[0].numero = this.formAtendimento.get('endereco.numero')?.value;
    this.currentClient.enderecos[0].complemento = this.formAtendimento.get('endereco.complemento')?.value;

    const plano = this.selectedPlano; // O plano escolhido (semanal, quinzenal, etc.)
    const dataInicio = moment(this.selectedDate, 'YYYY-MM-DD'); // A data de início do primeiro atendimento
    const dataFim = moment(this.selectedDateFim, 'YYYY-MM-DD'); // A data de fim do atendimento

    if (this.selectedServiceId) {
      this.preco = this.getPrice(this.selectedServiceId, this.hourSelected, plano.plano);
    } else {
      this.preco = this.getPrice(1, this.hourSelected, plano.plano);
    }

    // Validações
    if (!plano || !dataInicio || !dataFim) {
      console.log('Dados insuficientes para gerar os atendimentos.');
      return;
    }

    // Lista de datas selecionadas
    const datasSelecionadas: string[] = [];

    // Verificar se o plano é 'avulso' e criar um único atendimento
    if (plano.plano === 'avulso') {
      const dataSelecionada = `${dataInicio.format('YYYY-MM-DD')} (${dataInicio.isoWeekday()})`;
      datasSelecionadas.push(dataSelecionada);

      const atendimentoAvulso = {
        ...formValues, // Clona todos os campos do formulário
        data_inicio: dataInicio.format('YYYY-MM-DD') || '', // A data de início do atendimento avulso
        data_fim: dataInicio.clone().add(2, 'hours').format('YYYY-MM-DD') || '', // Exemplo: duração de 2 horas
        plano: plano.plano, // Atualiza o plano para 'avulso'
        cliente: this.currentClient, // Adiciona o cliente
        endereco: this.currentEndereco, // Adiciona o endereço
        servicos: [{ ID: this.selectedServiceId }],
        duracao: this.getTimeFromNumber(this.hourSelected),
        valor_servicos: this.preco.valor,
        valor_total: this.preco.valor,
        observacoes_de_prestador: this.msgProfissional,
        hora_de_entrada: this.selectedTime,
        datas_selecionadas: JSON.stringify(datasSelecionadas) // Adiciona datas no formato desejado
      };

      console.log('Atendimento Avulso Gerado:', atendimentoAvulso);
      this.saveAtendimentos([atendimentoAvulso]);

      // Atualizar o campo 'datas_selecionadas' no formulário para o atendimento avulso
      this.formAtendimento.patchValue({
        datas_selecionadas: JSON.stringify(datasSelecionadas)
      });

      return; // Sai da função, pois não precisamos de mais atendimentos
    }

    // Variáveis para controlar os intervalos e o número de atendimentos por semana
    let intervaloDias = 0;
    let atendimentosPorSemana = 1; // Padrão para semanal e quinzenal

    // Definindo o intervalo e o número de atendimentos por semana com base no plano
    switch (plano.plano) {
      case 'semanal':
        intervaloDias = 7; // Intervalo de 7 dias para semanal
        break;
      case 'quinzenal':
        intervaloDias = 14; // Intervalo de 14 dias para quinzenal
        break;
      case '2x':
        intervaloDias = 3; // Aproximadamente 3 dias de intervalo entre os atendimentos na semana
        atendimentosPorSemana = 2; // 2 atendimentos por semana
        break;
      case '3x':
        intervaloDias = 2; // Aproximadamente 2 dias de intervalo entre os atendimentos na semana
        atendimentosPorSemana = 3; // 3 atendimentos por semana
        break;
      case '4x':
        intervaloDias = 1; // 1 ou 2 dias de intervalo
        atendimentosPorSemana = 4; // 4 atendimentos por semana
        break;
      case '5x':
        intervaloDias = 1; // 1 dia de intervalo
        atendimentosPorSemana = 5; // 5 atendimentos por semana
        break;
      case '6x':
        intervaloDias = 1; // 1 dia de intervalo
        atendimentosPorSemana = 6; // 6 atendimentos por semana
        break;
      case '7x':
        intervaloDias = 1; // Sem intervalo (diariamente)
        atendimentosPorSemana = 7; // 7 atendimentos por semana (diários)
        break;
      default:
        console.log('Plano não suportado.');
        return;
    }

    // Gerar lista de atendimentos e datas selecionadas
    const atendimentos = [];
    let proximaDataAtendimento = dataInicio.clone(); // Começa com a data de início

    // Enquanto a data do próximo atendimento estiver dentro do intervalo permitido
    while (proximaDataAtendimento.isSameOrBefore(dataFim)) {
      for (let i = 0; i < atendimentosPorSemana; i++) {
        if (proximaDataAtendimento.isSameOrBefore(dataFim)) {
          const diaDaSemana = proximaDataAtendimento.isoWeekday(); // Dia da semana (segunda = 1, domingo = 7)

          // Clonar os valores do formulário, mas remover cliente e endereco
          const { cliente, endereco, ...formSemClienteEndereco } = formValues;
          const atendimento = {
            ...formSemClienteEndereco, // Clona todos os campos exceto cliente e endereco
            data_inicio: proximaDataAtendimento.format('YYYY-MM-DD'), // Data de início do atendimento
            data_fim: dataFim.format('YYYY-MM-DD'), // Exemplo: atendimento de 2 horas
            plano: plano.plano, // Atualiza o plano de cada atendimento
            cliente: this.currentClient, // Adiciona o cliente
            endereco: this.currentEndereco, // Adiciona o endereço
            servicos: [{ ID: this.selectedServiceId }],
            duracao: this.getTimeFromNumber(this.hourSelected),
            valor_servicos: this.preco.valor,
            valor_total: this.preco.valor,
            observacoes_de_prestador: this.msgProfissional,
            hora_de_entrada: this.selectedTime,
            datas_selecionadas: JSON.stringify([`${proximaDataAtendimento.format('YYYY-MM-DD')} (${diaDaSemana})`]) // Adiciona datas formatadas
          };

          atendimentos.push(atendimento);

          // Formatar a data selecionada com o dia da semana no formato "2023-11-11 (6)"
          const dataSelecionada = `${proximaDataAtendimento.format('YYYY-MM-DD')} (${diaDaSemana})`;
          datasSelecionadas.push(dataSelecionada);
        }

        // Próximo atendimento com intervalo definido
        proximaDataAtendimento.add(intervaloDias, 'days');
      }
    }

    // Atualizar o campo 'datas_selecionadas' no formulário
    this.formAtendimento.patchValue({
      datas_selecionadas: JSON.stringify(datasSelecionadas)
    });

    console.log('Lista de Atendimentos Gerada:', atendimentos);
    this.saveAtendimentos(atendimentos);
  }



  calculatePreco() {
    const plano = this.selectedPlano;
    if (plano && this.selectedServiceId) {
      if (this.selectedServiceId) {
        this.preco = this.getPrice(this.selectedServiceId, this.hourSelected, plano.plano);
      } else {
        this.preco = this.getPrice(1, this.hourSelected, plano.plano);
      }
    } else {
      this.preco = null;
    }
  }


  async saveAtendimentos(atendimentos: any[]) {
    this.showLoading();
    console.log(atendimentos);

    try {
      this.atendimentoService.saveListAtendimentos(atendimentos)
      .subscribe({
        next: (res: any) => {
          console.log(res);
          this.hideLoading();
          this.modalConfirm.present();
          this.animation = true;
          const modal = this.modalConfirm;
          modal.onDidDismiss().then(() => {
            this.navegate('services')
        });

        },
        error: (err: any) => {
          console.log(err);
          console.log(err.error);
          this.hideLoading();
        },
        complete: () => {

        },
      });
      console.log(this.currentClient);
      this.atualizaEndereco()
      await this.storage.set('atendimentos', atendimentos);
      await Preferences.set({
        key: 'user_data',
        value: JSON.stringify(this.currentClient),
      });
      const user = await this.getUserSecurely();
      console.log(user);
      //this.router.navigate(['services/confirm']);
    } catch (error) {
      console.error('Erro ao salvar os atendimentos:', error);
    }
  }

  getPrice(serviceId: number, duration: number, planType: string):any{
    const service = this.services.find(s => s.ID === serviceId);
    if (!service) {
      return null
    }
    const matchingPrice = service!.Precos.find((price: any) =>
      price.horas === duration && price.tipo === planType
    );
    if (!matchingPrice) {
      return null
    }
    return matchingPrice
  }

  getTimeFromNumber(hours: number): string {
    const formattedHours = hours < 10 ? `0${hours}` : `${hours}`;
    return `${formattedHours}:00`;
  }

  validateFields() {
    this.missingFields = []
    // Verificando campos do formulário que são obrigatórios
    const formValues = this.formAtendimento.getRawValue();
    if (!formValues.nome) this.missingFields.push('Nome');
    if (!formValues.CPF) this.missingFields.push('CPF');
    if (!formValues.endereco.cep) this.missingFields.push('CEP');
    if (!formValues.endereco.rua) this.missingFields.push('Rua');
    if (!formValues.endereco.bairro) this.missingFields.push('Bairro');
    if (!formValues.endereco.numero) this.missingFields.push('Digite o numero do endereço');
    if (!this.selectedTime) this.missingFields.push('Escolha o horario do atendimento');
    if (!this.hourSelected) this.missingFields.push('Escolha a duração do atendimento');

    // Verificar os campos que não fazem parte do formulário
    if (!this.currentClient) this.missingFields.push('Cliente');
    if (!this.currentEndereco) this.missingFields.push('Endereço');
    if (!this.selectedServiceId) this.missingFields.push('Selecione um serviço');

    // Se o plano não for avulso, verificar se a data de fim está preenchida
    if (this.selectedPlano.plano !== 'avulso' && !this.selectedDateFim) {
      this.missingFields.push('Selecione a data de encerramento');
    }

    // Retorna true se não houver campos faltantes, ou false com a lista de campos faltantes
    if (this.missingFields.length > 0) {
      this.showMissingFieldsAlert(this.missingFields);
      return false;
    }
    return true;
  }

  async showMissingFieldsAlert(missingFields: string[]) {
    console.log(missingFields);
    await this.modalMissing.present();
  }

  isPrecoValid(): boolean {
    return this.preco && typeof this.preco.valor === 'number' && this.preco.valor > 0;
  }

  atualizaEndereco(){
    this.enderecoService.putEndereco(this.currentEndereco).subscribe({
      next: (data) => {
        console.log('Cliente atualizado:', data);
      },
      error: (err) => {
        console.error('Erro ao atualizar o cliente:', err);
      }
    })
  }

  navegate(rota:any){
    this.router.navigate([rota]);
  }

  showLoading() {
    this.loadingComponent.createLoading();
  }

  hideLoading() {
    this.loadingComponent.dismissLoading();
  }


}
