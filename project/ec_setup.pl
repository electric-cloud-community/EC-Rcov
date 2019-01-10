my %runRcov = (
    label       => "Rcov - Code Coverage",
    procedure   => "runRcov",
    description => "Integrates rcov into Electric Commander",
    category    => "Code Analysis"
);

$batch->deleteProperty("/server/ec_customEditors/pickerStep/rcov - Run rcov");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/EC-Rcov - runRcov");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/Rcov - Code Coverage");

@::createStepPickerSteps = (\%runRcov);
