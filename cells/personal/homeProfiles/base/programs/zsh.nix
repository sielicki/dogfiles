{
  enable = true;
  defaultKeymap = "emacs";
  envExtra = ''
    autoload -U select-word-style
    select-word-style bash
    setopt interactivecomments
  '';
  history = {
    save = 10000000;
    size = 10000000;
    ignoreSpace = true;
    extended = true;
    share = true;
  };
}
