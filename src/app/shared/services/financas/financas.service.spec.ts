import { TestBed } from '@angular/core/testing';

import { FinancasService } from './financas.service';

describe('FinancasService', () => {
  let service: FinancasService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(FinancasService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
