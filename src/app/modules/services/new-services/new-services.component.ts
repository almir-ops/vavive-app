import { AfterViewInit, Component, OnInit, ViewChild } from '@angular/core';
import { AbstractControl, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { AlertController, IonicSlides, IonModal, PickerController } from '@ionic/angular';
import * as moment from 'moment';
import { Preferences } from '@capacitor/preferences';
import { Storage } from '@ionic/storage-angular';
import { ServicosService } from 'src/app/shared/services/servicos/servicos.service';
import { uPlano } from 'src/app/shared/interfaces/uPlano';
import { ViacepService } from 'src/app/shared/services/viacep/viacep.service';
import { ActivatedRoute, Router } from '@angular/router';
import { ClientesService } from 'src/app/shared/services/clientes/clientes.service';
import { EnderecosService } from 'src/app/shared/services/enderecos/enderecos.service';
import { AtendimentosService } from 'src/app/shared/services/atendimentos/atendimentos.service';
import { LoadingComponent } from 'src/app/shared/components/loading/loading.component';
import { AnimationOptions } from 'ngx-lottie';
import { AnimationItem } from 'lottie-web';
import { CuponsService } from 'src/app/shared/services/cupons/cupons.service';
import { Moment } from 'moment';
import { AlertService } from 'src/app/shared/services/alert.service';
import { Browser } from '@capacitor/browser';
import { ProfissionalService } from 'src/app/shared/services/profissional/profissional.service';
import { FinancasService } from 'src/app/shared/services/financas/financas.service';
import { PagamentosService } from 'src/app/shared/services/pagamentos/pagamentos.service';
import { EmailService } from 'src/app/shared/services/email/email.service';
import { CalculadoraServico } from 'src/app/shared/services/calculadora/calculadora.service';

@Component({
  selector: 'app-new-services',
  templateUrl: './new-services.component.html',
  styleUrls: ['./new-services.component.scss'],
})
export class NewServicesComponent  implements OnInit,AfterViewInit {


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


  @ViewChild('modalDateInitPlan', { static: false }) modalDateInitPlan!: IonModal;
  @ViewChild('modalDateInit', { static: false }) modalDateInit!: IonModal;
  @ViewChild('modalDateFim', { static: false }) modalDateFim!: IonModal;
  @ViewChild('modalMissing', { static: false }) modalMissing!: IonModal;
  @ViewChild('modalConfirm', { static: false }) modalConfirm!: IonModal;
  @ViewChild('modalEnderecos', { static: false }) modalEnderecos!: IonModal;
  @ViewChild('modalCupom', { static: false }) modalCupom!: IonModal;
  @ViewChild('modalDuvidas', { static: false }) modalDuvidas!: IonModal;


  services = [
    { ID: 1, icon:'./assets/icons/home.svg' ,icon_secundario:'./assets/icons/home-white.svg' , Precos: [], nome: 'Limpeza residencial', slogan: 'Limpeza completa de sua casa, cuidando de todos os ambientes.', descricao: '' },

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
  type!:string;
  addressesFound:any[] = [];
  multipleAddresses = false;
  expandInfoValue = true;
  currentCupom:any;
  currentCupomName:any;
  cupomInvalid = false;
  currentCupomProv:any;
  startDate!: Moment;
  highlightedDates: Array<{ date: string; textColor: string; backgroundColor: string }> = [];
  addressList:any;
  simpleScreen = false;
  selectServiceSimple!: any;

  selectedDates: string[] = [];
  maxSelectableDates: number = 1;
  countSelectedDates: number = 0;

  weekDays: any[] = [];
  monthNumber: any;
  primeiroAgendamento:any;

  allowedWeekDays: number[] = [1, 2, 3, 4, 5]; // Apenas segunda a sexta-feira
  currentFranquia: any;
  serviceNameSelected = '';

  constructor(
    private formBuilder: FormBuilder,
    private pickerCtrl: PickerController,
    private storage: Storage,
    private servicos: ServicosService,
    private viaCep: ViacepService,
    private router: Router,
    private cupomService: CuponsService,
    private route: ActivatedRoute,
    private enderecoService: EnderecosService,
    private atendimentoService: AtendimentosService,
    private servicosServices:ServicosService,
    private alertService: AlertService,
    private profissionalService: ProfissionalService,
    private financasService: FinancasService,
    private pagamentoService: PagamentosService,
    private emailService: EmailService,
    private calculadoraServico: CalculadoraServico,
  ) { }

  isWeekday = (dateString: string) => {
    const date = moment(dateString);
    const today = moment().startOf('day');
    const currentYear = today.year();

    // Lista de feriados fixos com ano dinâmico
    const feriados = [
      `${currentYear}-01-01`, // Confraternização Universal
      `${currentYear}-04-21`, // Tiradentes
      `${currentYear}-05-01`, // Dia do Trabalhador
      `${currentYear}-09-07`, // Independência
      `${currentYear}-12-25`, // Natal
    ];

    const isWeekend = date.isoWeekday() === 6 || date.isoWeekday() === 7;
    const isHoliday = feriados.includes(date.format('YYYY-MM-DD'));
    const isWithinNextTwoDays = date.diff(today, 'days') <= 1;

    return !isWeekend && !isHoliday && !isWithinNextTwoDays;
  };

  ngOnInit() {
    moment.locale('pt-br');
    this.initializeForm();
    this.loadNextFiveDays();
    this.loadNextFiveDaysFinal();
    this.setMinDate();
    this.generateTimeOptions();
    this.loadUserData();
    this.weekDays = Array.from({ length: 31 }, (_, i) => i + 1);
    this.selectedPlano = this.planos[0];

    this.route.queryParams.subscribe(params => {
      this.type = params['tipo'];
      const i = params['i'];

      if (this.type) {
        this.servicosServices.getServicos().subscribe({
          next: (value: any) => {
            console.log(value);

            // Filtra os serviços indesejados
            const filteredItems = value.items.filter((item: any) =>
              item.nome !== 'Limpeza pesada' &&
              item.nome !== 'Babá' &&
              item.nome !== 'Cuidador de idosos' &&
              item.nome !== 'Limpeza pós-obra' &&
              item.nome !== 'Recrutamento e seleção'
            );

            // Ordena os serviços desejados
            filteredItems.sort((a: any, b: any) => {
              if (a.nome === 'Limpeza residencial') return -1;
              if (b.nome === 'Limpeza residencial') return 1;
              if (a.nome === 'Limpeza empresarial') return -1;
              if (b.nome === 'Limpeza empresarial') return 1;
              return 0;
            });

            this.services = filteredItems;

            // Converte o tipo selecionado para número e encontra o serviço correspondente
            this.selectedServiceId = parseInt(this.type, 10);

            const selectedService = value.items.find(
              (service: any) => service.ID === this.selectedServiceId
            );

            // Encontra o índice do serviço selecionado na lista filtrada e ordenada
            this.indexServiceSelected = filteredItems.findIndex(
              (service: any) => service.ID === this.selectedServiceId
            );

            // Armazena o nome do serviço na variável
            if (this.indexServiceSelected !== -1) {
              this.serviceNameSelected = filteredItems[this.indexServiceSelected].nome;
            }

            console.log('Índice do serviço selecionado:', this.indexServiceSelected);

            if (selectedService) {
              console.log('Selected Service Name:', selectedService.nome);
              this.selectServiceSimple = selectedService;

              // Define this.simpleScreen como true para os serviços específicos
              const simpleScreenServices = [
                'Babá',
                'Cuidador de idosos',
                'Limpeza pós-obra',
                'Limpeza pesada'
              ];

              this.simpleScreen = simpleScreenServices.includes(selectedService.nome);
            }
          },
          error: (err: any) => {
            console.log(err);
          },
        });

      }else{
        console.log('Nenhum tipo de serviço selecionado.');
        this.servicosServices.getServicos().subscribe({
          next: (value: any) => {
            console.log(value);
            const filteredItems = value.items.filter((item: any) => item.nome !== 'Limpeza pesada' && item.nome !== 'Babá' && item.nome !== 'Cuidador de idosos'&& item.nome !== 'Limpeza pós-obra'&& item.nome !== 'Limpeza pesada');

            filteredItems.sort((a: any, b: any) => {
              if (a.nome === 'Limpeza residencial') return -1;
              if (b.nome === 'Limpeza residencial') return 1;
              if (a.nome === 'Limpeza empresarial') return -1;
              if (b.nome === 'Limpeza empresarial') return 1;
              return 0;
            });
            this.services = filteredItems;


          },
          error: (err: any) => {
            console.log(err);
          },
        });
      }
    });

    this.getFranquiaInfo();

  }

  ngAfterViewInit() {
    this.servicos.getServicos().subscribe({
      next: (data) => {
        this.services = this.services.map(service => {
          const updatedService = data.items.find((apiService: any) => apiService.ID === service.ID);
          return updatedService ? { ...service, Precos: updatedService.Precos } : service;
        });
      },
      error: (err) => {
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
      status_pagamento: ['Pendente'],
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
      datas_selecionadas: [],
      cupom:[]
    });
  }

  async loadUserData() {
    try {
      const user = await this.getUserSecurely();

      if (user) {
        this.currentClient = user;
        const cep = await this.storage.get('current_cep');
        console.log(user);
        console.log(cep);
        console.log(this.currentClient);


        //this.addressesFound = this.currentClient.enderecos.filter((endereco:any) => endereco.cep.replace("-", "") === cep);
        this.addressesFound = this.currentClient.enderecos;
        this.addressList = this.currentClient.enderecos;
        console.log(this.addressesFound);

        this.updateClientData();
        if(this.addressList.length === 1){
          this.getCurrentCep();
          this.currentEndereco = this.addressList[0]
        }else if (this.addressesFound.length > 1){
          this.multipleAddresses = true
        }else if (this.addressList.length === 0){
          this.getCurrentCep();
        }else{
          this.currentEndereco = this.addressesFound[0];

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
      console.log(cep);

      if (cep) {
        this.currentEndereco.cep = cep;
        this.viaCep.buscarEndereco(cep).subscribe({
          next:(val:any)=>{
            console.log(val);
            this.currentEndereco.rua = val.logradouro;
            this.currentEndereco.bairro = val.bairro;
            this.currentEndereco.cidade = val.localidade;
            this.currentEndereco.estado = val.uf;
            //this.currentEndereco.complemento = val.complemento;
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
    this.nextFiveDays = [];
    let daysAdded = 0;
    let i = 2;

    while (daysAdded < 3) {
      const date = moment().add(i, 'days');

      if (date.isoWeekday() !== 6 && date.isoWeekday() !== 7) {
        this.nextFiveDays.push({
          dayOfWeek: this.getAbbreviation(date.format('dddd')),
          dateNumber: date.format('DD'),
          dateMonth: date.format('MM'),
          fullDate: date.format('YYYY-MM-DD')
        });
        daysAdded++;
      }

      i++;
    }
  }

  loadNextFiveDaysFinal() {
    this.nextFiveDaysFinal = Array.from({ length: 3 }, (_, i) => {
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
    if (this.hourSelected < 8) {
      this.hourSelected += 2;
      this.selectedTime = '';
      this.hourInit = this.selectedTime;

      this.calculatePreco();
    }
  }

  downHour() {
    if (this.hourSelected > 4) {
      this.hourSelected -= 2;
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

/*
  onDateSelected(event: any) {
    this.selectedDate = moment(event.detail.value).format('YYYY-MM-DD');
    this.modalDateInit.dismiss();
  }
*/

onDateSelected(event: any) {
  console.log(this.maxSelectableDates);
  console.log(this.countSelectedDates);

  if(this.countSelectedDates === this.maxSelectableDates){
    this.selectedDate = '';
    console.log(this.countSelectedDates);

  }else{
    if(this.selectedPlano.plano === 'avulso'){
      this.selectedDates = [];
      this.countSelectedDates = 0;
      const selectedDate = Array.isArray(event.detail.value)
      ? event.detail.value[event.detail.value.length - 1]
      : event.detail.value;
      this.selectedDate = selectedDate;
      this.selectedDates.push(selectedDate);
      this.modalDateInit.dismiss();
    }else{
      this.countSelectedDates++;
      // Pega o valor selecionado do evento
    const selectedDate = Array.isArray(event.detail.value)
    ? event.detail.value[event.detail.value.length - 1] // Pega a última data se for um array
    : event.detail.value; // Usa diretamente se não for um array

    if (!selectedDate) {
    return;
    }

    // Verifica se a data já está na lista de selectedDates
    const dateAlreadySelected = this.selectedDates.some(
    (date) => new Date(date).getTime() === new Date(selectedDate).getTime()
    );

    if (dateAlreadySelected) {
    // Restaura o estado das datas selecionadas no componente
    const datetimeElement = document.querySelector('#datetime') as HTMLIonDatetimeElement;
    if (datetimeElement) {
      datetimeElement.value = [...this.selectedDates]; // Restaura as datas selecionadas
    }
    return; // Sai do método sem tomar nenhuma ação
    }

    // Atualiza o valor da última data selecionada
    this.selectedDate = selectedDate;

    if (!this.selectedDateFim) {
    alert("Defina uma data final para o agendamento.");
    return;
    }

    // Calcula as datas subsequentes
    const calculatedDates = this.calculateSubsequentDates(selectedDate, this.selectedDateFim);

    // Atualiza o array de datas selecionadas com as novas datas
    const selectedCustomDates = [...this.selectedDates, ...calculatedDates];
    this.selectedDates = selectedCustomDates;
    this.selectedDates.sort((a, b) => new Date(a).getTime() - new Date(b).getTime());

    this.dayValues();

    // Atualiza o estado do componente datetime
    const datetimeElement = document.querySelector('#datetime') as HTMLIonDatetimeElement;
    if (datetimeElement) {
    datetimeElement.value = [...this.selectedDates]; // Atualiza as datas selecionadas
      if(this.countSelectedDates === this.maxSelectableDates){
      this.weekDays = [];
      }
    }
    }

    }
    this.calculatePreco();

}



calculateSubsequentDates(startDate: string, endDate: string): string[] {
  const resultDates: string[] = [];
  const start = new Date(startDate);
  const end = new Date(endDate);
  const dayOfWeek = start.getDay();

  if (start > end) {
    return [];
  }

  let currentDate = start;

  while (currentDate <= end) {
    if (currentDate.getDay() === dayOfWeek) {
      resultDates.push(currentDate.toISOString().split("T")[0]); // Adiciona a data no formato ISO

      // Se o plano for quinzenal, pula uma semana (7 dias * 2)
      if (this.selectedPlano.plano === 'quinzenal') {
        currentDate.setDate(currentDate.getDate() + 14);
        continue;
      }
    }
    currentDate.setDate(currentDate.getDate() + 1); // Incrementa o dia para planos normais
  }

  return resultDates;
}



updatePlano(uPlano: any) {
  this.selectedDates = []; // Reseta as datas selecionadas
  const plano = uPlano.plano;

  if (plano === '2x') {
    this.maxSelectableDates = 2;
  } else if (plano === '3x') {
    this.maxSelectableDates = 3;
  } else if (plano === '4x') {
    this.maxSelectableDates = 4;
  } else if (plano === '5x') {
    this.maxSelectableDates = 5;
  } else if (plano === '6x') {
    this.maxSelectableDates = 6;
  } else if (plano === '7x') {
    this.maxSelectableDates = 7;
  }  else {
    this.maxSelectableDates = 1;
  }
}


getWeekNumber(date: string): number {
  const dt = new Date(date);

  if (isNaN(dt.getTime())) {
    return NaN;
  }

  const startOfYear = new Date(dt.getFullYear(), 0, 1);
  const diffInDays = Math.floor((dt.getTime() - startOfYear.getTime()) / 86400000);
  const dayOfWeek = startOfYear.getDay();

  return Math.ceil((diffInDays + dayOfWeek) / 7);
}

  dayValues() {
    if (!this.selectedDate) {
      return undefined;
    }

    const selectedDate = new Date(this.selectedDate);

    const monthNumber = selectedDate.getMonth() + 1;

    this.monthNumber = monthNumber
    const startOfWeek = Math.floor((selectedDate.getDate()) / 7) * 7 + 1;
    const endOfWeek = Math.min(
      startOfWeek + 6,
      new Date(selectedDate.getFullYear(), selectedDate.getMonth() + 1, 0).getDate()
    );

    const weekDays = [];
    for (let day = startOfWeek; day <= endOfWeek; day++) {
      weekDays.push(day);
    }

    this.weekDays = weekDays;
  }

  resetSelection(){
    this.selectedDates = [];
    this.countSelectedDates = 0;
    this.selectedDate = '';
    this.weekDays = Array.from({ length: 31 }, (_, i) => i + 1);
  }

  onDateSelectedFinal(event: any) {
    this.selectedDateFim = event.detail.value;
    this.modalDateFim.dismiss();
  }

  selectHour(hora:string) {
    if(this.hourSelected === 4){
      this.selectedTime = hora;
      this.hourInit = this.selectedTime;
    }else{
      this.selectedTime = '08:00';
      this.hourInit = this.selectedTime;
      this.alertService.presentAlert('Atenção','Para serviços acima de 4 horas só poderá ser agendado para as 08:00 horas.');
    }
  }

  confirmAtendimentoPlan(){
    if(this.maxSelectableDates === this.countSelectedDates){
      this.modalDateInit.dismiss();
    }else{
      this.alertService.presentAlert('Atenção','Selecione o número máximo de datas para o plano selecionado.');
    }
  }

  openModalDataInicio(){
    if(this.selectedDateFim){
      this.modalDateInit.present();
    }else{
      this.alertService.presentAlert('Atenção','Selecione de encerramento dos atendimentos antes de selecionar a data de início.');

    }
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
    console.log(this.formAtendimento.value);
    const dataInicio = moment(this.selectedDate, 'YYYY-MM-DD'); // A data de início do primeiro atendimento
    const dataFim = moment(this.selectedDateFim, 'YYYY-MM-DD'); // A data de fim do atendimento

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
        servicos: [{ ID: this.selectedServiceId, nome:this.serviceNameSelected }],
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


    const atendimentos: any[] = []; // Especifica o tipo de atendimentos

    this.selectedDates.forEach((dateStr: string) => {
      const date = new Date(dateStr); // Converte a string para um objeto Date
      const diaDaSemana = date.getDay(); // Obtém o dia da semana (0 = domingo, 1 = segunda, ..., 6 = sábado)

      // Clonar os valores do formulário, mas remover cliente e endereco
      const { cliente, endereco, ...formSemClienteEndereco } = formValues;
      const atendimento = {
        ...formSemClienteEndereco, // Clona todos os campos exceto cliente e endereco
        data_inicio: dateStr, // Data de início do atendimento (no formato original)
        data_fim: dataFim.format('YYYY-MM-DD'), // Exemplo: atendimento de 2 horas (formato 'YYYY-MM-DD')
        plano: plano.plano, // Atualiza o plano de cada atendimento
        cliente: this.currentClient, // Adiciona o cliente
        endereco: this.currentEndereco, // Adiciona o endereço
        servicos: [{ ID: this.selectedServiceId, nome:this.serviceNameSelected}],
        duracao: this.getTimeFromNumber(this.hourSelected),
        valor_servicos: this.preco.valor,
        valor_total: this.preco.valor,
        observacoes_de_prestador: this.msgProfissional,
        hora_de_entrada: this.selectedTime,
        datas_selecionadas: JSON.stringify([`${dateStr} (${diaDaSemana})`]) // Adiciona datas formatadas
      };

      atendimentos.push(atendimento);

      // Formatar a data selecionada com o dia da semana no formato "2023-11-11 (6)"
      const dataSelecionada = `${dateStr} (${diaDaSemana})`;
      datasSelecionadas.push(dataSelecionada);
    });

    // Atualizar o campo 'datas_selecionadas' no formulário
    this.formAtendimento.patchValue({
      datas_selecionadas: JSON.stringify(datasSelecionadas)
    });

    console.log('Lista de Atendimentos Gerada:', atendimentos);
    this.saveAtendimentos(atendimentos);
  }



  calculatePreco() {
    console.log('calculatePreco');

    const plano = this.selectedPlano;

    if (plano && this.selectedServiceId) {
      if (this.selectedServiceId) {
        this.preco = this.getPrice(this.selectedServiceId, this.hourSelected, plano.plano);
      } else {
        this.preco = this.getPrice(1, this.hourSelected, plano.plano);
      }
    } else {
      this.preco = null;
      console.log(this.preco);

    }
    console.log(this.preco);
  }


  async saveAtendimentos(atendimentos: any[]) {
    try {
      this.atendimentoService.saveListAtendimentos(atendimentos)
      .subscribe({
        next: (res: any) => {
          console.log(res);
          this.primeiroAgendamento = res.item[0];
          this.handlePaymentNow();
          //this.modalConfirm.present();
          this.animation = true;
          const modal = this.modalConfirm;
          modal.onDidDismiss().then(() => {
            this.navegate('services');
          });
          this.updateCupom();
          },
          error: (err: any) => {
            console.log(err);
            console.log(err.error);
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

  getPrice(serviceId: number, duration: number, planType: string): any {
    const service = this.services.find(s => s.ID === serviceId);
    console.log(service);

    if (!service) {
      return null;
    }

    const matchingPrice = service.Precos.find((price: any) =>
      price.horas === duration && price.tipo === planType
    );

    if (matchingPrice) {
      return matchingPrice;
    }

    // fallback: tenta calcular o valor usando a calculadora
    const valorCalculado = this.calculadoraServico.calcularValor(planType.toLowerCase(), duration, 'sp');
    console.log(valorCalculado);

    return {
      valor: valorCalculado,
      origem: 'calculado'
    };
  }


  getTimeFromNumber(hours: number): string {
    const formattedHours = hours < 10 ? `0${hours}` : `${hours}`;
    return `${formattedHours}:00`;
  }

  validateFields() {
    this.missingFields = [];
    // Verificando campos do formulário que são obrigatórios
    const formValues = this.formAtendimento.getRawValue();

    if (!formValues.nome) this.missingFields.push('Nome');
    if (!formValues.CPF) this.missingFields.push('CPF');
    if (!formValues.endereco.cep) this.missingFields.push('CEP');
    if (!formValues.endereco.rua) this.missingFields.push('Rua');
    if (!formValues.endereco.bairro) this.missingFields.push('Bairro');
    if (!formValues.endereco.numero) this.missingFields.push('Digite o número do endereço');
    if (!this.selectedTime) this.missingFields.push('Escolha o horário do atendimento');
    if (!this.hourSelected) this.missingFields.push('Escolha a duração do atendimento');

    // Verificar os campos que não fazem parte do formulário
    if (!this.currentClient) this.missingFields.push('Cliente');
    if (!this.currentEndereco) this.missingFields.push('Endereço');
    if (!this.selectedServiceId) this.missingFields.push('Selecione um serviço');

    // Verificar data_inicio com formato 'YYYY-MM-DD'
    const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
    if (!this.selectedDate || !dateRegex.test(this.selectedDate)) {
      this.missingFields.push('Data de início inválida ou ausente');
    }

    // Se o plano não for avulso, verificar se a data de fim está preenchida
    if (this.selectedPlano.plano !== 'avulso' && !this.selectedDateFim) {
      this.missingFields.push('Selecione a data de encerramento');
    }
    console.log(this.preco);

    if (formValues.valor_servicos <= 0 && (this.preco && this.preco.valor <= 0)) {
      this.missingFields.push('O valor dos serviços deve ser maior que 0');
    }
    if (formValues.valor_total <= 0 && (this.preco && this.preco.valor <= 0)) {
      this.missingFields.push('O valor total deve ser maior que 0');
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

  selectAdress(endereco:any){
    console.log(endereco);

    this.currentEndereco = endereco;
    this.updateClientData();
    this.multipleAddresses = false;
    this.modalEnderecos.dismiss();
  }

  searchCupom() {
    this.cupomInvalid = false;
    this.cupomService.getCuponsByFilters('?nome=' + this.currentCupomName).subscribe({
      next: (data) => {
        console.log(data);
        if (data.items) {
          const cupom = data.items[0];
          const isQuantity = cupom.quandidade === cupom.usados;
          const isPlanDifferentFromAvulsoAndExtra = this.selectedPlano.plano !== 'avulso' && this.selectedPlano.plano !== 'extra';

          if (
            cupom.ativo &&
            cupom.status === 'Disponivel' &&
            moment().isSameOrBefore(moment(cupom.data_validade), 'day') &&
            !isQuantity &&
            (!isPlanDifferentFromAvulsoAndExtra || cupom.recorrente === "true") // Verificação ajustada
          ) {
            console.log(this.selectedPlano);
            this.currentCupomProv = cupom;
          } else {
            this.cupomInvalid = true;
          }
        }
      },
      error: (err) => {
        console.error('Erro ao buscar cupons:', err);
      }
    });
  }

  applyCupom(){
      this.currentCupom = this.currentCupomProv
      this.formAtendimento.controls['cupom'].setValue(this.currentCupom);
      this.formAtendimento.controls['desconto'].setValue(this.currentCupom.valor);
      this.preco.valor -= this.currentCupom.valor;
      this.modalCupom.dismiss();
  }

  updateCupom(){
    if(this.currentCupom){
      this.currentCupom.usados += 1;
      if(this.currentCupom.quantidade === this.currentCupom.usados){
        this.currentCupom.status = 'Usado';
      }
      this.currentCupom.ativo = false;
      this.cupomService.putCupons(this.currentCupom).subscribe({
        next: (data) => {
          console.log(data);
        },
        error: (err) => {
          console.error('Erro ao atualizar cupom:', err);
        }
      })
    }
  }
  removeCupom(){
    this.formAtendimento.controls['cupom'].setValue('');
    this.formAtendimento.controls['desconto'].setValue('')
    this.preco.valor += this.currentCupom.valor;
    this.currentCupom = null;
  }

/*
  onDateSelectedPlan(event: any) {
    this.startDate = moment(event.detail.value);
    console.log("Data de início selecionada:", this.startDate.format('YYYY-MM-DD'));
    this.highlightedDates = this.generateHighlightedDates();
  }

  generateHighlightedDates(): Array<{ date: string; textColor: string; backgroundColor: string }> {
    const endDate = moment(this.selectedDateFim);
    console.log("Data final:", endDate.format('YYYY-MM-DD'));

    const dates: Array<{ date: string; textColor: string; backgroundColor: string }> = [];

    if (this.selectedPlano.plano === 'semanal') {
      let currentDate = moment(this.startDate);
      console.log("Plano semanal - gerando datas:");
      while (currentDate.isSameOrBefore(endDate)) {
        dates.push(this.formatHighlightedDate(currentDate));
        console.log("Data adicionada:", currentDate.format('YYYY-MM-DD'));
        currentDate = currentDate.add(1, 'weeks'); // Adiciona uma semana
      }
    } else if (this.selectedPlano.plano === 'quinzenal') {
      let currentDate = moment(this.startDate);
      console.log("Plano quinzenal - gerando datas:");
      while (currentDate.isSameOrBefore(endDate)) {
        dates.push(this.formatHighlightedDate(currentDate));
        console.log("Data adicionada:", currentDate.format('YYYY-MM-DD'));
        currentDate = currentDate.add(2, 'weeks'); // Adiciona 2 semanas
      }
    } else if (this.selectedPlano.plano === '2x-semana') {
      let currentDate = moment(this.startDate);
      console.log("Plano 2x por semana - gerando datas:");
      while (currentDate.isSameOrBefore(endDate)) {
        dates.push(this.formatHighlightedDate(currentDate)); // Segunda
        console.log("Data adicionada (segunda):", currentDate.format('YYYY-MM-DD'));

        let nextDay = moment(currentDate).add(1, 'days'); // Terça
        if (nextDay.isSameOrBefore(endDate)) {
          dates.push(this.formatHighlightedDate(nextDay));
          console.log("Data adicionada (terça):", nextDay.format('YYYY-MM-DD'));
        }
        currentDate = currentDate.add(1, 'weeks'); // Próxima semana
      }
    }

    console.log("Todas as datas geradas:", dates);
    return dates;
  }

  formatHighlightedDate(date: moment.Moment): { date: string; textColor: string; backgroundColor: string } {
    const formattedDate = {
      date: date.format('YYYY-MM-DD'), // Formato do Ionic
      textColor: '#ffffff',
      backgroundColor: '#007BFF' // Cor de fundo para destacar a data
    };
    console.log("Data formatada para destaque:", formattedDate);
    return formattedDate;
  }
*/

handlePaymentNow(){

  if(this.primeiroAgendamento){
    this.financasService.getFinancasByFilter('?atendimento_id=' + this.primeiroAgendamento.ID).subscribe({
      next: (response:any) => {
        console.log(response);

        const entradas = response.items.filter((item: any) => item.tipo === 'Entrada');
        console.log(entradas);
        const pagamento = {
          value: entradas[0].valor,
          financa: entradas[0].ID,
          billingType: "UNDEFINED",
          dueDate: moment().add(3, 'days').format('YYYY-MM-DD')
        }
        this.pagamentoService.criaPagamento(pagamento).subscribe({
          next: async (res: any) => {
            console.log(res);
            await Browser.open({ url: res.data.invoiceUrl });
            this.modalConfirm.dismiss();
            this.navegate('services/pagamentos');

          },
          error: (err: any) => {
            console.log(err);
            this.alertService.presentAlert('Erro ', `Erro ao gerar cobrança`);
            this.emailService.sendEmail('Erro ao gerar cobrança, atendimento OS: '+ this.primeiroAgendamento.ID ,this.generateErroEmail(this.primeiroAgendamento, err),'almir_jesus2@hotmail.comng ').subscribe({
              next:(value:any) =>{
                console.log(value);
              },
              error:(err:any) => {
                console.log(err);
              },
            })
          }
        })
      },error: (response:any)=> {
        console.log(response);
      }
    })
  }
}

goToPaymentsList(){
  this.modalConfirm.dismiss();
  this.navegate('services/pagamentos');
}

goToScheduling(){
  this.modalConfirm.dismiss();
  this.navegate('services');
}

async openWhatsApp() {
  try {
    // Obtém o número de contato do storage
    const contato = await this.storage.get('contato_franquia');

    // Usa número padrão se o contato não existir ou for inválido
    const numeroPadrao = '5521991514398';

    // Verifica se o contato existe e tem números válidos
    const formattedNumber = contato && contato.replace(/\D/g, '').length > 0
      ? contato.replace(/\D/g, '')
      : numeroPadrao;

    // Monta a URL para abrir o WhatsApp
    const whatsappURL = `https://wa.me/${formattedNumber}`;

    // Abre o WhatsApp em uma nova aba/janela
    window.open(whatsappURL, '_blank');
  } catch (error) {
    console.error('Erro ao tentar abrir o WhatsApp:', error);
    alert('Houve um erro ao processar a solicitação.');
  }
}

generateEmail(id: any, atendimento: any): string {
  if (!this.formAtendimento) return '';
  const logoUrl = 'https://lirp.cdn-website.com/6d9e534c/dms3rep/multi/opt/vavive21-1920w.png';
  const endereco = atendimento.endereco;
  const cliente = atendimento.cliente;
  const selectedService = this.services.find((service: any) => service.ID === this.selectedServiceId);
  return `
    <img src="${logoUrl}" alt="Logo" style="max-width: 150px; margin-bottom: 20px;" /><br>
    Olá, <strong>${atendimento.nome}</strong>!<br>
    Ficamos muito felizes em poder ajudar o seu dia!<br>
    ____________________________________________________________<br><br>
    <strong>Informações de Atendimento:</strong><br>
    Franquia Responsável: ${this.currentFranquia}<br>
    Serviço Selecionado: ${selectedService?.nome || ''}<br>
    OS: ${id}<br>
    Plano Selecionado: ${atendimento.plano}<br>
    Data de Início: ${atendimento.data_inicio ? moment(atendimento.data_inicio).format('DD/MM/YYYY') : ''}<br>
    Data de Fim: ${atendimento.data_fim ? moment(atendimento.data_fim).format('DD/MM/YYYY') : ''}<br>
    Hora de Entrada: A partir de ${atendimento.hora_de_entrada}<br>
    Duração: ${this.hourSelected} HORAS<br>
    Status do Pagamento: ${atendimento.status_pagamento}<br>
    Desconto: R$ ${atendimento.desconto?.toFixed(2) || '0.00'}<br>
    Acréscimo: R$ ${atendimento.acrestimo?.toFixed(2) || '0.00'}<br>
    Valor dos Serviços: R$ ${atendimento.valor_servicos?.toFixed(2) || '0.00'}<br>
    Valor Total: R$ ${atendimento.valor_total?.toFixed(2) || '0.00'}<br>
    Observações de Serviço: ${atendimento.observacoes_de_servicos || ''}<br>
    Observações do Prestador: ${atendimento.observacoes_de_prestador || ''}<br>
    ____________________________________________________________<br><br>
    <strong>Suas Informações:</strong><br>
    CPF: ${cliente?.cpf || ''}<br>
    Telefone: ${cliente?.celular || ''}<br>
    Email: ${cliente?.email || ''}<br>
    Rua: ${endereco?.rua}, Nº ${endereco?.numero}<br>
    Bairro: ${endereco?.bairro}<br>
    Cidade: ${endereco?.cidade} - ${endereco?.estado}<br>
    CEP: ${endereco?.cep}, País: ${endereco?.pais || ''}<br>
    Complemento: ${endereco?.complemento || ''}<br>
    ____________________________________________________________<br>
    Qualquer dúvida, <a href="https://wa.me/5521991514398" target="_blank">clique aqui</a><br>
    Deixe com a gente e VAVIVÊ!<br>
    <img src="${logoUrl}" alt="Logo" style="max-width: 150px; margin-top: 20px;" />

  `;
}

generateErroEmail(atendimento: any, erro:any): string {
  if (!this.formAtendimento) return '';
  const selectedService = this.services.find((service: any) => service.ID === this.selectedServiceId);
  return `
    Olá, <strong>${atendimento.nome}</strong>!<br>
    Ouve um erro ao gerar cobrança <br>
    ____________________________________________________________<br><br>
    <strong>Informações de Atendimento:</strong><br>
    Franquia Responsável: ${this.currentFranquia}<br>
    ____________________________________________________________<br><br>
    <strong>Erro:</strong><br>
     ${erro}<br>


  `;
}


async getFranquiaInfo(){
  const franquia = await this.storage.get('franquia');
  this.currentFranquia = franquia;
  console.log(this.currentFranquia);
}

}
