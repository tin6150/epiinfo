# EUCAST Antibiotic-to-Class Mapping (Keys = Antibiotics, Values = Classes)
# src: https://www.eucast.org/bacteria/clinical-breakpoints-and-interpretation/clinical-breakpoint-tables/
ab_class_mapping <- c(
  # Penicillins [cite: 16, 18]
  "Benzylpenicillin" = "Penicillins",
  "Ampicillin" = "Penicillins",
  "Ampicillin-sulbactam" = "Penicillins",
  "Amoxicillin" = "Penicillins",
  "Amoxicillin-clavulanic acid" = "Penicillins",
  "Piperacillin" = "Penicillins",
  "Piperacillin-tazobactam" = "Penicillins",
  "Ticarcillin-clavulanic acid" = "Penicillins",
  "Temocillin" = "Penicillins",
  "Phenoxymethylpenicillin" = "Penicillins",
  "Oxacillin" = "Penicillins",
  "Cloxacillin" = "Penicillins",
  "Dicloxacillin" = "Penicillins",
  "Flucloxacillin" = "Penicillins",
  "Mecillinam" = "Penicillins",

  # Cephalosporins [cite: 19]
  "Cefaclor" = "Cephalosporins",
  "Cefadroxil" = "Cephalosporins",
  "Cefalexin" = "Cephalosporins",
  "Cefazolin" = "Cephalosporins",
  "Cefepime" = "Cephalosporins",
  "Cefepime-enmetazobactam" = "Cephalosporins",
  "Cefiderocol" = "Cephalosporins",
  "Cefixime" = "Cephalosporins",
  "Cefotaxime" = "Cephalosporins",
  "Cefoxitin" = "Cephalosporins",
  "Cefpodoxime" = "Cephalosporins",
  "Ceftaroline" = "Cephalosporins",
  "Ceftazidime" = "Cephalosporins",
  "Ceftazidime-avibactam" = "Cephalosporins",
  "Ceftibuten" = "Cephalosporins",
  "Ceftobiprole" = "Cephalosporins",
  "Ceftolozane-tazobactam" = "Cephalosporins",
  "Ceftriaxone" = "Cephalosporins",
  "Cefuroxime" = "Cephalosporins",

  # Carbapenems [cite: 20, 28]
  "Doripenem" = "Carbapenems",
  "Ertapenem" = "Carbapenems",
  "Imipenem" = "Carbapenems",
  "Imipenem-relebactam" = "Carbapenems",
  "Meropenem" = "Carbapenems",
  "Meropenem-vaborbactam" = "Carbapenems",

  # Monobactams [cite: 29]
  "Aztreonam" = "Monobactams",
  "Aztreonam-avibactam" = "Monobactams",

  # Fluoroquinolones [cite: 30]
  "Ciprofloxacin" = "Fluoroquinolones",
  "Pefloxacin" = "Fluoroquinolones",
  "Delafloxacin" = "Fluoroquinolones",
  "Levofloxacin" = "Fluoroquinolones",
  "Moxifloxacin" = "Fluoroquinolones",
  "Nalidixic acid" = "Fluoroquinolones",
  "Norfloxacin" = "Fluoroquinolones",
  "Ofloxacin" = "Fluoroquinolones",

  # Aminoglycosides [cite: 31, 33]
  "Amikacin" = "Aminoglycosides",
  "Gentamicin" = "Aminoglycosides",
  "Netilmicin" = "Aminoglycosides",
  "Tobramycin" = "Aminoglycosides",

  # Glycopeptides and lipoglycopeptides [cite: 34]
  "Dalbavancin" = "Glycopeptides and lipoglycopeptides",
  "Oritavancin" = "Glycopeptides and lipoglycopeptides",
  "Teicoplanin" = "Glycopeptides and lipoglycopeptides",
  "Telavancin" = "Glycopeptides and lipoglycopeptides",
  "Vancomycin" = "Glycopeptides and lipoglycopeptides",

  # Macrolides, lincosamides and streptogramins [cite: 35]
  "Azithromycin" = "Macrolides, lincosamides and streptogramins",
  "Clarithromycin" = "Macrolides, lincosamides and streptogramins",
  "Erythromycin" = "Macrolides, lincosamides and streptogramins",
  "Roxithromycin" = "Macrolides, lincosamides and streptogramins",
  "Clindamycin" = "Macrolides, lincosamides and streptogramins",
  "Quinupristin-dalfopristin" = "Macrolides, lincosamides and streptogramins",

  # Tetracyclines [cite: 36]
  "Doxycycline" = "Tetracyclines",
  "Eravacycline" = "Tetracyclines",
  "Minocycline" = "Tetracyclines",
  "Tetracycline" = "Tetracyclines",
  "Tigecycline" = "Tetracyclines",

  # Oxazolidinones [cite: 37]
  "Linezolid" = "Oxazolidinones",
  "Tedizolid" = "Oxazolidinones",

  # Miscellaneous agents [cite: 38, 39]
  "Chloramphenicol" = "Miscellaneous agents",
  "Colistin" = "Miscellaneous agents",
  "Daptomycin" = "Miscellaneous agents",
  "Fosfomycin" = "Miscellaneous agents",
  "Fusidic acid" = "Miscellaneous agents",
  "Gepotidacin" = "Miscellaneous agents",
  "Lefamulin" = "Miscellaneous agents",
  "Metronidazole" = "Miscellaneous agents",
  "Nitrofurantoin" = "Miscellaneous agents",
  "Nitroxoline" = "Miscellaneous agents",
  "Rifampicin" = "Miscellaneous agents",
  "Spectinomycin" = "Miscellaneous agents",
  "Trimethoprim" = "Miscellaneous agents",
  "Trimethoprim-sulfamethoxazole" = "Miscellaneous agents"
)
