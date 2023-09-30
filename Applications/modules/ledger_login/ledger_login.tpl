
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="Mark Otto, Jacob Thornton, and Bootstrap contributors">
    <meta name="generator" content="Jekyll v3.8.6">
    <title>LedgerWeb - Login</title>

    <!-- Bootstrap core CSS -->
<link href="/svnroot/Applications/common/bootstrap.min.css" rel="stylesheet">

    <!-- Favicons -->
<link rel="apple-touch-icon" href="/docs/4.4/assets/img/favicons/apple-touch-icon.png" sizes="180x180">
<link rel="icon" href="/docs/4.4/assets/img/favicons/favicon-32x32.png" sizes="32x32" type="image/png">
<link rel="icon" href="/docs/4.4/assets/img/favicons/favicon-16x16.png" sizes="16x16" type="image/png">
<link rel="manifest" href="/docs/4.4/assets/img/favicons/manifest.json">
<link rel="mask-icon" href="/docs/4.4/assets/img/favicons/safari-pinned-tab.svg" color="#563d7c">
<link rel="icon" href="/docs/4.4/assets/img/favicons/favicon.ico">
<meta name="msapplication-config" content="/docs/4.4/assets/img/favicons/browserconfig.xml">
<meta name="theme-color" content="#563d7c">
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>

    <style>
      .bd-placeholder-img {
        font-size: 1.125rem;
        text-anchor: middle;
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
        user-select: none;
      }

      @media (min-width: 768px) {
        .bd-placeholder-img-lg {
          font-size: 3.5rem;
        }
      }
    </style>
    <!-- Custom styles for this template -->
    <link href="/svnroot/Applications/common/cover.css" rel="stylesheet">
  </head>
  <body class="text-center">
    <div class="cover-container d-flex w-100 h-100 p-3 mx-auto flex-column">
  <header class="masthead mb-auto">
    <div class="inner">
      <h3 class="masthead-brand">LedgerWeb</h3>
      <nav class="nav nav-masthead justify-content-center">
        <a class="nav-link active" href="#">Home</a>
        <a class="nav-link" href="#">Features</a>
        <a class="nav-link" href="#">Contact</a>
      </nav>
    </div>
  </header>

  <main role="main" class="inner cover">
    <h1 class="cover-heading">Login.</h1>
    <p class="lead">&nbsp;</p>
    

<style>
.lw-form-icon {
	width: 18px;
}
</style>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">

<form>
<input type=hidden name=posted value=true>
  <div class="form-group row">
    <label for="text" class="col-4 col-form-label">Regnskab</label> 
    <div class="col-8">
      <div class="input-group">
        <div class="input-group-prepend">
          <div class="input-group-text">
            <i class="fa fa-book lw-form-icon"></i>
          </div>
        </div> 
        <input id="text" name="regnskab" value="{$input.regnskab}" type="text" class="form-control">
     </div>
    </div>
  </div>
  <div class="form-group row">
    <label for="text2" class="col-4 col-form-label">Brugernavn</label> 
    <div class="col-8">
      <div class="input-group">
        <div class="input-group-prepend">
          <div class="input-group-text">
            <i class="fa fa-user lw-form-icon"></i>
          </div>
        </div> 
        <input id="text2" name="username" value="{$input.username}" type="text" class="form-control">
      </div>
    </div>
  </div>
  <div class="form-group row">
    <label for="text1" class="col-4 col-form-label">Adgangskode</label> 
    <div class="col-8">
      <div class="input-group">
        <div class="input-group-prepend">
          <div class="input-group-text">
            <i class="fa fa-lock lw-form-icon"></i>
          </div>
        </div> 
        <input id="text1" name="password" type="password" class="form-control">
      </div>
        <div class="error"></div> 
    </div>
  </div> 
    <p class="lead">
      <button class="btn btn-lg btn-secondary">Log ind</button>
    </p>
</form>
  </main>

<script>
{if $errorMessage}
$(function() {
	$(".error").css("color","red");
	$(".error").html("{$errorMessage}");
	$("input[name=regnskab]").focus();	
});
{/if}
</script>

  <footer class="mastfoot mt-auto">
    <div class="inner">
      <p>Copyright &copy; 2000-2020 <a href="https://olsensrevision.dk/">Olsens Revision</a>.</p>
    </div>
  </footer>
</div>
</body>
</html>

