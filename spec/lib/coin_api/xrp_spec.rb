describe CoinAPI::XRP do
  let(:client) { CoinAPI[:xrp] }

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  describe '#create_address!' do
    subject { client.create_address! }

    let :request_body do
      { jsonrpc: '1.0',
        id:      1,
        method:  'wallet_propose',
        params:  [passphrase: 'pass@word']
      }.to_json
    end

    let :response_body do
      '{"result":{"account_id":"rHviZLF88ZXMjxGXdg3V7GJkSntZsDxwAU","key_type":"secp256k1","master_key":"LUKE BRIG SOWN DANK BARD HOLD THIS SEAM HOFF SLY MILT GAM","master_seed":"ssJdTYgpmsbsQ8EU1j7e2DEr1LsBW","master_seed_hex":"2BB87B1E6502BBEA322B95378CE3EBB3","public_key":"aBQDi8A2inLWhTzgzisDt7qGfLL3Pkqz9jTx2hFvu1NnX6N3rfQy","public_key_hex":"032A43F4FDCEDFF9AE85F66CA169BAA9C0E46E578AA81D2C4B6099FF7FD1BA395C","status":"success","warning":"This wallet was generated using a user-supplied passphrase that has low entropy and is vulnerable to brute-force attacks."}}'
    end

    before do
      Passgen.stubs(:generate).returns('pass@word')
      stub_request(:post, 'http://127.0.0.1:5005/').with(body: request_body).to_return(body: response_body)
    end

    it do
      is_expected.to eq \
        address:         'rHviZLF88ZXMjxGXdg3V7GJkSntZsDxwAU',
        secret:          'pass@word',
        key_type:        'secp256k1',
        master_key:      'LUKE BRIG SOWN DANK BARD HOLD THIS SEAM HOFF SLY MILT GAM',
        master_seed:     'ssJdTYgpmsbsQ8EU1j7e2DEr1LsBW',
        master_seed_hex: '2BB87B1E6502BBEA322B95378CE3EBB3',
        public_key:      'aBQDi8A2inLWhTzgzisDt7qGfLL3Pkqz9jTx2hFvu1NnX6N3rfQy',
        public_key_hex:  '032A43F4FDCEDFF9AE85F66CA169BAA9C0E46E578AA81D2C4B6099FF7FD1BA395C'
    end
  end

  describe '#load_balance!' do
    subject(:load_balance!) { client.load_balance! }

    let :request_body do
      { jsonrpc: '1.0',
        id:      1,
        method:  'account_info',
        params:  [account: 'rwHGuJBDgLdh63SuBwos7vYmc8J2PptPLL', ledger_index: 'validated', strict: true]
      }.to_json
    end

    let :response_body do
      '{"result":{"account_data":{"Account":"rwHGuJBDgLdh63SuBwos7vYmc8J2PptPLL","Balance":"10000000000","Flags":0,"LedgerEntryType":"AccountRoot","OwnerCount":0,"PreviousTxnID":"0AA806F7DF8A3933ABBFAAA7F934998994EC6B8B4C5E4E2364E3B623A4D75DB5","PreviousTxnLgrSeq":7174833,"Sequence":1,"index":"77B04133968B4C8BA4968212ADDD25BDF7C574444A645361C4FF2E07244DD038"},"ledger_hash":"2655E928F5F3C1C95DC093000E2706013BA56397CA55497C9E51625FA2018F04","ledger_index":7175480,"status":"success","validated":true}}'
    end

    before do
      create(:payment_address, currency: client.currency, address: 'rwHGuJBDgLdh63SuBwos7vYmc8J2PptPLL')
      stub_request(:post, 'http://127.0.0.1:5005/').with(body: request_body).to_return(body: response_body)
    end

    it 'returns balance' do
      expect(load_balance!).to eq('10000'.to_d)
    end
  end

  describe '#inspect_address!' do
    context 'valid address' do
      let(:address) { 'rwHGuJBDgLdh63SuBwos7vYmc8J2PptPLL' }
      subject { client.inspect_address!(address) }
      it { is_expected.to eq({ address: address, is_valid: true, is_mine: :unsupported }) }
    end

    context 'invalid address' do
      let(:address) { '0x42eb768f2244c8811c63729a21a3569731535f06' }
      subject { client.inspect_address!(address) }
      it { is_expected.to eq({ address: address, is_valid: false, is_mine: :unsupported }) }
    end
  end

  describe '#each_deposit!' do
    subject { client.each_deposit! }

    let :request_body do
      { jsonrpc: '1.0',
        id:      1,
        method:  'tx_history',
        params:  [start: 0]
      }.to_json
    end

    let :response_body do
      '{"result":{"index":0,"status":"success","txs":[{"Account":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Amount":"20000000","Destination":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Fee":"12","Flags":2147483648,"LastLedgerSequence":7175700,"Sequence":9057959,"SigningPubKey":"02E6CB923A531044CB194A2F7477B38C6D2B499FA67FFC38203CEADC7D8A7DFF54","TransactionType":"Payment","TxnSignature":"3045022100DAAB1982F94AC5FFDF89E953A0F0CCE49AA7FBE040C67BD2D2474EA4597DA6BD022054A3C758FD6C0671C00AADE27B72E72134D98DE67FF4CEDCE2E7BAC06EEE717F","hash":"357653EF0B1076029B4FDDC2D7073E513FFF98DCA9E863458DA859B58262D2C2","inLedger":7175699,"ledger_index":7175699},{"Account":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Amount":"20000000","Destination":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Fee":"12","Flags":2147483648,"LastLedgerSequence":7175700,"Sequence":9045326,"SigningPubKey":"02A61C710649C858A03DF50C8D24563613FC4D905B141EEBE019364675929AB804","TransactionType":"Payment","TxnSignature":"3045022100E719282CBCC36D1808D97C4964A3BF1BCB8CB6BEC57AC8A2A104F5E3AA82C9DA02205A73C445A77B7B0DE8172F09DDA762BB377BE8C4E0402FD3B157C643DDD761B8","hash":"1C777D89035CF3647F3FC9DDDC87F8D0F2DBE38C65F4A8BD083425A148879604","inLedger":7175699,"ledger_index":7175699},{"Account":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Amount":"20000000","Destination":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Fee":"12","Flags":2147483648,"LastLedgerSequence":7175699,"Sequence":9057958,"SigningPubKey":"02E6CB923A531044CB194A2F7477B38C6D2B499FA67FFC38203CEADC7D8A7DFF54","TransactionType":"Payment","TxnSignature":"3045022100D0BB14AFAEA0C92422D5B46ED7EA36441E46FEAF0F62FD398166B62655C93B500220421E41909963577C3BC66466C95B53BC56C861E42272CB977668DAE86D21C890","hash":"49993933E4C24F91FBE080C71A584E1944543BDC0E44699BED8202C1217F8794","inLedger":7175698,"ledger_index":7175698},{"Account":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Amount":"20000000","Destination":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Fee":"12","Flags":2147483648,"LastLedgerSequence":7175699,"Sequence":9057957,"SigningPubKey":"02E6CB923A531044CB194A2F7477B38C6D2B499FA67FFC38203CEADC7D8A7DFF54","TransactionType":"Payment","TxnSignature":"304402201DA0DE62A47FB43B7EA474841A850163F8EC10C453EA34F02C3C4A6F3B31F79002203324139404563E87F29E40C7C95866C8BEE0716D5FEDD665B1922121B7740925","hash":"28B8B3DE696218B518156009B27A8E5E9F655E82F677B016BEC9A2AE52C655A0","inLedger":7175698,"ledger_index":7175698},{"Account":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Amount":"20000000","Destination":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Fee":"12","Flags":2147483648,"LastLedgerSequence":7175700,"Sequence":9045325,"SigningPubKey":"02A61C710649C858A03DF50C8D24563613FC4D905B141EEBE019364675929AB804","TransactionType":"Payment","TxnSignature":"30450221008C00961D27AD3327CD15F306F2F6527A59674EB4CA5FFE2FDF251096606F5DD40220272CA509624A8103394CD7B3CBA071C52B732CE70D0794A6DFE91BFCF21E6977","hash":"00BFCB3D617D56E4D0A9634E2938F90330DC766912777B5103B8F299F563A693","inLedger":7175698,"ledger_index":7175698},{"Account":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Amount":"20000000","Destination":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Fee":"12","Flags":2147483648,"LastLedgerSequence":7175699,"Sequence":9045324,"SigningPubKey":"02A61C710649C858A03DF50C8D24563613FC4D905B141EEBE019364675929AB804","TransactionType":"Payment","TxnSignature":"30440220699915E53D62668BC81931BA848DAA0265F4C5433C961E2BA55EC1E589D8745B02202251B3885468F00F6E916E91A8DC8213CE772B18A6D43F3A17D69FFC88E3FC9B","hash":"26A63CFBD4C507FFB137E56A50B5BC5644244D3563946F8D4D0397299936B0B8","inLedger":7175698,"ledger_index":7175698},{"Account":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Amount":"20000000","Destination":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Fee":"12","Flags":2147483648,"LastLedgerSequence":7175698,"Sequence":9045323,"SigningPubKey":"02A61C710649C858A03DF50C8D24563613FC4D905B141EEBE019364675929AB804","TransactionType":"Payment","TxnSignature":"304402200B1512CCBDCF917FB1A3262B528885A78D1F232E924113835F10E270BD1A99E302201751780C4583368DCE686C57D86EABEC21693514A66C1771E689239ECC145314","hash":"87C954C7CF41A1473D2C836316317E430082DAB075F1E2B35B49403922F4A4C1","inLedger":7175697,"ledger_index":7175697},{"Account":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Amount":"20000000","Destination":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Fee":"12","Flags":2147483648,"LastLedgerSequence":7175698,"Sequence":9057956,"SigningPubKey":"02E6CB923A531044CB194A2F7477B38C6D2B499FA67FFC38203CEADC7D8A7DFF54","TransactionType":"Payment","TxnSignature":"3044022015C996FD63B8DD013C1C4110FF217F4E0B1315E9751C361BA5DB983CA0207D35022013E1CB46CDD9657D332628420C3912130D8345854888E42948163B13B4738B7F","hash":"604A5549CD4FF669B02C98B143ADED73CBF980AF757895A4FB421A9D6AE6E6FA","inLedger":7175697,"ledger_index":7175697},{"Account":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Amount":"20000000","Destination":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Fee":"12","Flags":2147483648,"LastLedgerSequence":7175698,"Sequence":9045322,"SigningPubKey":"02A61C710649C858A03DF50C8D24563613FC4D905B141EEBE019364675929AB804","TransactionType":"Payment","TxnSignature":"3045022100FF3874E3E03E5463749B2074FB01BD0EAB0A2B459140B0860ACA7578054F748A022016CF2313621505606C7CFA9173F764E181480075B02F14F0C8343DE99E404E38","hash":"65231D1E0AE10EB469C4B7CFB8642D6A61AE1BF1170F51525F5850C2BC78FF14","inLedger":7175696,"ledger_index":7175696},{"Account":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Amount":"20000000","Destination":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Fee":"12","Flags":2147483648,"LastLedgerSequence":7175697,"Sequence":9045321,"SigningPubKey":"02A61C710649C858A03DF50C8D24563613FC4D905B141EEBE019364675929AB804","TransactionType":"Payment","TxnSignature":"3045022100B0DFE55872B0FC59E1394F4A69A8A9AD524681086CA139E4559388EC1BE340FF02200E407369F0E885E69F67281AE0B545C73654E1C316B85D6BDD22AB67FAAC4CE1","hash":"96B2F916E712E2989C21D2C11F1D20F8C835EF6B4A0C0AF74FAF0B18A4DDFDDB","inLedger":7175696,"ledger_index":7175696},{"Account":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Amount":"20000000","Destination":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Fee":"12","Flags":2147483648,"LastLedgerSequence":7175697,"Sequence":9057955,"SigningPubKey":"02E6CB923A531044CB194A2F7477B38C6D2B499FA67FFC38203CEADC7D8A7DFF54","TransactionType":"Payment","TxnSignature":"304402200C7C09FCD5B041AE6084818E5EC37C1AFF88E2F1204CD9EFD3779389A2344E2402201E0BA2BE2916DC93BE866FD591D2606833034686C304B8419240EB235555ED14","hash":"D6AAF5A73A08B398A6945FAD8320A2B47611BBFB48D63F6CF395DF21621601D8","inLedger":7175696,"ledger_index":7175696},{"Account":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Amount":"20000000","Destination":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Fee":"12","Flags":2147483648,"LastLedgerSequence":7175697,"Sequence":9057954,"SigningPubKey":"02E6CB923A531044CB194A2F7477B38C6D2B499FA67FFC38203CEADC7D8A7DFF54","TransactionType":"Payment","TxnSignature":"3045022100F61E54F61EB7450C24A3537813B861FB207654F2142ED141478D29A2C502003C022079A67C99D71B11629C78351233D5D33B0B97514B489A307070C859B8218EE71B","hash":"79AAFBDE75407C793DEC57ACB5A94ADE248396D57C81FE2800724C1133841DDB","inLedger":7175696,"ledger_index":7175696},{"Account":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Amount":"20000000","Destination":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Fee":"12","Flags":2147483648,"LastLedgerSequence":7175696,"Sequence":9057953,"SigningPubKey":"02E6CB923A531044CB194A2F7477B38C6D2B499FA67FFC38203CEADC7D8A7DFF54","TransactionType":"Payment","TxnSignature":"3045022100EF68B20E56714C6F00AA895532A5DAADBBB9FA394D46E339CCE06C72BFC43E30022046CC45194707CD013728BA81B2DCECB7D639D69B6B61FBC1B65954ED8965F5B0","hash":"F7550C881A467088D8FF49671AF427E5CBFAE99DF950819CCB9FE6B3437C2BAA","inLedger":7175695,"ledger_index":7175695},{"Account":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Amount":"20000000","Destination":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Fee":"12","Flags":2147483648,"LastLedgerSequence":7175696,"Sequence":9045320,"SigningPubKey":"02A61C710649C858A03DF50C8D24563613FC4D905B141EEBE019364675929AB804","TransactionType":"Payment","TxnSignature":"3044022007CFC568D0BF55CE42AA52922F668EB88665A0972C555F305E1AA83BB77C12F702206AC33B8B6F794C1A536427E294D840BC3FDC3BFE3CDDB0AC1043BA1233F0BD14","hash":"2720E38A1D86A726D09A4821E62D2FF81D019870F27BDF59E8CF6998892D2798","inLedger":7175695,"ledger_index":7175695},{"Account":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Amount":"20000000","Destination":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Fee":"12","Flags":2147483648,"LastLedgerSequence":7175696,"Sequence":9045319,"SigningPubKey":"02A61C710649C858A03DF50C8D24563613FC4D905B141EEBE019364675929AB804","TransactionType":"Payment","TxnSignature":"3045022100B1F482E099B21EF439695FE832EE10CF1946C414C213F188B7DE57308E359A9D02201EF35877970DC6D5F82DFD295CABC60725CAE1F6F59696E658EB915D4BD66693","hash":"06A276AC741D2590CD0D7668EEA8F49FD3EE7CB76DA61C8DC5FE82F0D0C382DE","inLedger":7175694,"ledger_index":7175694},{"Account":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Amount":"20000000","Destination":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Fee":"12","Flags":2147483648,"LastLedgerSequence":7175695,"Sequence":9045318,"SigningPubKey":"02A61C710649C858A03DF50C8D24563613FC4D905B141EEBE019364675929AB804","TransactionType":"Payment","TxnSignature":"3045022100CE65C9A2954C7A1BB1B8433E6D23D84E67D310E5908256CE2C3881C8648A1CED022013961A4FC0B38DC81A817FA550C7C406DC62C1DB9AF75595F0CDF3A3847F914A","hash":"5A744BFB82BA0693BD87BF3265673C356B4EAC3DD748389D9DD13AD535FA40F1","inLedger":7175694,"ledger_index":7175694},{"Account":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Amount":"20000000","Destination":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Fee":"12","Flags":2147483648,"LastLedgerSequence":7175695,"Sequence":9057952,"SigningPubKey":"02E6CB923A531044CB194A2F7477B38C6D2B499FA67FFC38203CEADC7D8A7DFF54","TransactionType":"Payment","TxnSignature":"30450221008D234142521A7BDC24C0D5EE8624E32E8E0F89B6298DE96E3438C722563805F402204D0150A18A2A00B983864491D7AA3AFBACA90BFDC8AFD1A14A2115F11B86BA59","hash":"F83C2E47D3BE95C6B626519A38C4316E73913B6F805669E39D8D1567B56BA05B","inLedger":7175694,"ledger_index":7175694},{"Account":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Amount":"20000000","Destination":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Fee":"12","Flags":2147483648,"LastLedgerSequence":7175695,"Sequence":9057951,"SigningPubKey":"02E6CB923A531044CB194A2F7477B38C6D2B499FA67FFC38203CEADC7D8A7DFF54","TransactionType":"Payment","TxnSignature":"304402202BD2A69DAB60D59986BFA5D0C45AB223AAD937EF87E2D5F72A3CC799199DDEDD02206D7DF20FDBB6F0779001101A13E4EE7B2F0E2AF2CF5357F0AA085715E169CAD6","hash":"AA34EB25C64ABC1776AFEDB0105BAB036F5AAE237856F544F41B90DB729AE4B3","inLedger":7175694,"ledger_index":7175694},{"Account":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Amount":"20000000","Destination":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Fee":"12","Flags":2147483648,"LastLedgerSequence":7175694,"Sequence":9057950,"SigningPubKey":"02E6CB923A531044CB194A2F7477B38C6D2B499FA67FFC38203CEADC7D8A7DFF54","TransactionType":"Payment","TxnSignature":"3045022100BF75782043FF174E5400FB2C088C070AD258AFD005BB64DAF282495D6B8C086D0220575F0E70836FDBEC42052290C3C765D11E389E47144F5196CC8EF6368956297E","hash":"8C0F56056BAF84D3AB5A84EFBC33A1E84A57A37B6D32109A735E785391C5F552","inLedger":7175693,"ledger_index":7175693},{"Account":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Amount":"20000000","Destination":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Fee":"12","Flags":2147483648,"LastLedgerSequence":7175694,"Sequence":9045317,"SigningPubKey":"02A61C710649C858A03DF50C8D24563613FC4D905B141EEBE019364675929AB804","TransactionType":"Payment","TxnSignature":"304502210087EB7B1DE25A09ED68ACAFC4E04620163A79BEB53AD9E5461D7FCDB199AFF06402203DAC4D3D8AA5DBA79E920E1C4112743046F363D6EFDB4BD0103C154D832BCB1D","hash":"6BD1A810F425DD9B167AD7156FE56F602187ECA9907BB61FDFEF7DA7CF85B211","inLedger":7175693,"ledger_index":7175693}]}}'
    end

    before do
      client.expects(:more_deposits_available?).returns(false)
      stub_request(:post, 'http://127.0.0.1:5005/').with(body: request_body).to_return(body: response_body)
    end

    it do
      expected = JSON.load('[{"id":"357653EF0B1076029B4FDDC2D7073E513FFF98DCA9E863458DA859B58262D2C2","confirmations":1,"entries":[{"amount":20.0,"address":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr"}]},{"id":"1C777D89035CF3647F3FC9DDDC87F8D0F2DBE38C65F4A8BD083425A148879604","confirmations":1,"entries":[{"amount":20.0,"address":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM"}]},{"id":"49993933E4C24F91FBE080C71A584E1944543BDC0E44699BED8202C1217F8794","confirmations":1,"entries":[{"amount":20.0,"address":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr"}]},{"id":"28B8B3DE696218B518156009B27A8E5E9F655E82F677B016BEC9A2AE52C655A0","confirmations":1,"entries":[{"amount":20.0,"address":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr"}]},{"id":"00BFCB3D617D56E4D0A9634E2938F90330DC766912777B5103B8F299F563A693","confirmations":2,"entries":[{"amount":20.0,"address":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM"}]},{"id":"26A63CFBD4C507FFB137E56A50B5BC5644244D3563946F8D4D0397299936B0B8","confirmations":1,"entries":[{"amount":20.0,"address":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM"}]},{"id":"87C954C7CF41A1473D2C836316317E430082DAB075F1E2B35B49403922F4A4C1","confirmations":1,"entries":[{"amount":20.0,"address":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM"}]},{"id":"604A5549CD4FF669B02C98B143ADED73CBF980AF757895A4FB421A9D6AE6E6FA","confirmations":1,"entries":[{"amount":20.0,"address":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr"}]},{"id":"65231D1E0AE10EB469C4B7CFB8642D6A61AE1BF1170F51525F5850C2BC78FF14","confirmations":2,"entries":[{"amount":20.0,"address":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM"}]},{"id":"96B2F916E712E2989C21D2C11F1D20F8C835EF6B4A0C0AF74FAF0B18A4DDFDDB","confirmations":1,"entries":[{"amount":20.0,"address":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM"}]},{"id":"D6AAF5A73A08B398A6945FAD8320A2B47611BBFB48D63F6CF395DF21621601D8","confirmations":1,"entries":[{"amount":20.0,"address":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr"}]},{"id":"79AAFBDE75407C793DEC57ACB5A94ADE248396D57C81FE2800724C1133841DDB","confirmations":1,"entries":[{"amount":20.0,"address":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr"}]},{"id":"F7550C881A467088D8FF49671AF427E5CBFAE99DF950819CCB9FE6B3437C2BAA","confirmations":1,"entries":[{"amount":20.0,"address":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr"}]},{"id":"2720E38A1D86A726D09A4821E62D2FF81D019870F27BDF59E8CF6998892D2798","confirmations":1,"entries":[{"amount":20.0,"address":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM"}]},{"id":"06A276AC741D2590CD0D7668EEA8F49FD3EE7CB76DA61C8DC5FE82F0D0C382DE","confirmations":2,"entries":[{"amount":20.0,"address":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM"}]},{"id":"5A744BFB82BA0693BD87BF3265673C356B4EAC3DD748389D9DD13AD535FA40F1","confirmations":1,"entries":[{"amount":20.0,"address":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM"}]},{"id":"F83C2E47D3BE95C6B626519A38C4316E73913B6F805669E39D8D1567B56BA05B","confirmations":1,"entries":[{"amount":20.0,"address":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr"}]},{"id":"AA34EB25C64ABC1776AFEDB0105BAB036F5AAE237856F544F41B90DB729AE4B3","confirmations":1,"entries":[{"amount":20.0,"address":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr"}]},{"id":"8C0F56056BAF84D3AB5A84EFBC33A1E84A57A37B6D32109A735E785391C5F552","confirmations":1,"entries":[{"amount":20.0,"address":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr"}]},{"id":"6BD1A810F425DD9B167AD7156FE56F602187ECA9907BB61FDFEF7DA7CF85B211","confirmations":1,"entries":[{"amount":20.0,"address":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM"}]}]').map(&:symbolize_keys)
      expected.each do |tx|
        tx[:entries].each(&:symbolize_keys!).each { |entry| entry[:amount] = entry[:amount].to_d }
      end
      is_expected.to eq expected
    end
  end

  describe '#load_deposit!' do
    let(:hash) { '20EE152281324F9EEB7940615EFCE64B8B34DDF5C1623FC300798F1F3DC34C42' }
    subject { client.load_deposit!(hash) }

    let :request_body do
      { jsonrpc: '1.0',
        id:      1,
        method:  'tx',
        params:  [transaction: '20EE152281324F9EEB7940615EFCE64B8B34DDF5C1623FC300798F1F3DC34C42']
      }.to_json
    end

    let :response_body do
      '{"result":{"Account":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Amount":"20000000","Destination":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Fee":"12","Flags":2147483648,"LastLedgerSequence":7174984,"Sequence":9056876,"SigningPubKey":"02E6CB923A531044CB194A2F7477B38C6D2B499FA67FFC38203CEADC7D8A7DFF54","TransactionType":"Payment","TxnSignature":"3045022100E8CCF607B88346353B642F654A28495C81CF2B8D2DACE138EB6915BEA9759B0B022063EECFB873F0F9C575CAFCB883AF1F622BC7B99422F9B0F5DEBF84B570E0D7E3","date":573396290,"hash":"20EE152281324F9EEB7940615EFCE64B8B34DDF5C1623FC300798F1F3DC34C42","inLedger":7174983,"ledger_index":7174983,"meta":{"AffectedNodes":[{"ModifiedNode":{"FinalFields":{"Account":"rDJFnv5sEfp42LMFiX3mVQKczpFTdxYDzM","Balance":"1620318429","Flags":0,"OwnerCount":0,"Sequence":9056877},"LedgerEntryType":"AccountRoot","LedgerIndex":"31794F29F9E987DC45A7997416503E0E3A5C0D114B050845B76F2D9D9FF9DC1F","PreviousFields":{"Balance":"1640318441","Sequence":9056876},"PreviousTxnID":"89158F549AE716D53D384A77CBFF7952923239164AC502DFEB4FA7A8A517C520","PreviousTxnLgrSeq":7174983}},{"ModifiedNode":{"FinalFields":{"Account":"rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr","Balance":"2165324238","Flags":0,"OwnerCount":0,"Sequence":9044242},"LedgerEntryType":"AccountRoot","LedgerIndex":"8EEC72369A874DEC57AC3C11F40714D79D56F0079AA1948B38CC044D3F6F79FF","PreviousFields":{"Balance":"2145324238"},"PreviousTxnID":"89158F549AE716D53D384A77CBFF7952923239164AC502DFEB4FA7A8A517C520","PreviousTxnLgrSeq":7174983}}],"TransactionIndex":1,"TransactionResult":"tesSUCCESS","delivered_amount":"20000000"},"status":"success","validated":true}}'
    end

    before do
      stub_request(:post, 'http://127.0.0.1:5005/').with(body: request_body).to_return(body: response_body)
    end

    it do
      is_expected.to eq \
        id:            '20EE152281324F9EEB7940615EFCE64B8B34DDF5C1623FC300798F1F3DC34C42',
        confirmations: 1,
        entries:       [{ address: 'rPm88mdDuXLgxzpmZPXf6wPQ1ZTHRNvYVr',
                          amount:  '20'.to_d }]
    end
  end

  describe 'create_withdrawal!' do
    let(:issuer) { { address: 'r9kNwEHobtSrdKhZ7EKJUuz3jMcwrc5xGV', secret: 'sn34YoVCdk67GfzKiiZgwdqzWNxXu' } }
    let(:recipient) { { address: 'rGMXupU8PVZRvxoLjbvEcuTt7gCYhdiEdM' } }
    subject { client.create_withdrawal!(issuer, recipient, 1000) }

    let :request_body do
      '{"jsonrpc":"1.0","id":1,"method":"submit","params":[{"secret":"sn34YoVCdk67GfzKiiZgwdqzWNxXu","fee_mult_max":1000,"tx_json":{"Account":"r9kNwEHobtSrdKhZ7EKJUuz3jMcwrc5xGV","Amount":1000000000,"Destination":"rGMXupU8PVZRvxoLjbvEcuTt7gCYhdiEdM","DestinationTag":0,"TransactionType":"Payment"}}]}'
    end

    let :response_body do
      '{"result":{"engine_result":"tesSUCCESS","engine_result_code":0,"engine_result_message":"The transaction was applied. Only final in a validated ledger.","status":"success","tx_blob":"1200002280000000240000000161400000003B9ACA0068400000000000000A732102C0F3CB3551AD3A2AD7446DD86E0ABCF9D3FAE724B72BB1C7B21F84CE4D43AB6A7446304402205C417CB4E2C4BE7D67A68D79ABFDAEBF35AF9FAEA685FD60B35F5B0F0FE41A11022041EF679F320CD01F8A407F6A6B8CB80F97E00C92EDF710C52E63C081EF5D782281145FEDE0A7A3E02B51DAF58E526555689AA0E7AC238314A86BFF57CE1F6085D86AB94C0338E905D1E4276D","tx_json":{"Account":"r9kNwEHobtSrdKhZ7EKJUuz3jMcwrc5xGV","Amount":"1000000000","Destination":"rGMXupU8PVZRvxoLjbvEcuTt7gCYhdiEdM","Fee":"10","Flags":2147483648,"Sequence":1,"SigningPubKey":"02C0F3CB3551AD3A2AD7446DD86E0ABCF9D3FAE724B72BB1C7B21F84CE4D43AB6A","DestinationTag":0,"TransactionType":"Payment","TxnSignature":"304402205C417CB4E2C4BE7D67A68D79ABFDAEBF35AF9FAEA685FD60B35F5B0F0FE41A11022041EF679F320CD01F8A407F6A6B8CB80F97E00C92EDF710C52E63C081EF5D7822","hash":"116AFBD721EE1C2E628AA801ACFBD40A7C21F7B125248127690A1CAA09D86C91"}}}'
    end

    before do
      stub_request(:post, 'http://127.0.0.1:5005/').with(body: request_body).to_return(body: response_body)
    end

    it { is_expected.to eq('116AFBD721EE1C2E628AA801ACFBD40A7C21F7B125248127690A1CAA09D86C91') }
  end

  describe 'address?' do
    subject { client.send(:address?, address) }

    context 'valid address' do
      let(:address) { 'rKM5oQ2NdaS3o8ran4PKsESnhfxzfUqCJm' }
      it { is_expected.to be_truthy }
    end

    context 'invalid address' do
      let(:address) { '0x42eb768f2244c8811c63729a21a3569731535f06' }
      it { is_expected.to be_falsey }
    end

    context 'valid address with destination tag' do
      let(:address) { 'rKM5oQ2NdaS3o8ran4PKsESnhfxzfUqCJm?dt=33722' }
      it { is_expected.to be_truthy }
    end

    context 'invalid address with destination tag' do
      let(:address) { 'rKM5oQ2NdaS3o8ran4PKsESnhfxzfUqCJm?dt=033722' }
      it { is_expected.to be_falsey }
    end
  end
end
