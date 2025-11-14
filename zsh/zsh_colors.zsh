#!/usr/bin/env zsh
# zsh_colors.zsh - Catppuccin Frappe color scheme for zsh
# Sets LS_COLORS and completion colors using Catppuccin Frappe palette

# Catppuccin Frappe color palette (ANSI 256-color codes)
# Base colors
export CATPPUCCIN_CRUST="#232634"
export CATPPUCCIN_BASE="#303446"
export CATPPUCCIN_MANTLE="#292c3c"
export CATPPUCCIN_SURFACE0="#414559"
export CATPPUCCIN_SURFACE1="#51576d"
export CATPPUCCIN_SURFACE2="#626880"
export CATPPUCCIN_OVERLAY0="#737994"
export CATPPUCCIN_OVERLAY1="#838ba7"
export CATPPUCCIN_OVERLAY2="#949cbb"
export CATPPUCCIN_SUBTEXT0="#a5adce"
export CATPPUCCIN_SUBTEXT1="#b5bfe2"
export CATPPUCCIN_TEXT="#c6d0f5"
export CATPPUCCIN_LAVENDER="#babbf1"
export CATPPUCCIN_BLUE="#8caaee"
export CATPPUCCIN_SAPPHIRE="#85c1dc"
export CATPPUCCIN_SKY="#99d1db"
export CATPPUCCIN_TEAL="#81c8be"
export CATPPUCCIN_GREEN="#a6d189"
export CATPPUCCIN_YELLOW="#e5c890"
export CATPPUCCIN_PEACH="#ef9f76"
export CATPPUCCIN_MAROON="#ea999c"
export CATPPUCCIN_RED="#e78284"
export CATPPUCCIN_MAUVE="#ca9ee6"
export CATPPUCCIN_PINK="#f4b8e4"
export CATPPUCCIN_FLAMINGO="#eebebe"
export CATPPUCCIN_ROSEWATER="#f2d5cf"

# LS_COLORS using Catppuccin Frappe colors
# Format: di=directory, fi=file, ln=symlink, ex=executable, etc.
# Colors are specified as: attribute;foreground;background
# Attributes: 00=none, 01=bold, 04=underscore, 05=blink, 07=reverse, 08=concealed
# ANSI 256-color codes for Catppuccin Frappe:
# Blue (directories): 111 (8caaee)
# Green (executables): 150 (a6d189)
# Yellow (archives): 222 (e5c890)
# Red (errors/important): 168 (e78284)
# Mauve (symlinks): 140 (ca9ee6)
# Teal (images): 73 (81c8be)
# Peach (audio): 209 (ef9f76)
# Pink (videos): 218 (f4b8e4)
# Sky (documents): 117 (99d1db)
# Sapphire (code files): 110 (85c1dc)

export LS_COLORS="\
di=01;38;5;111:\
fi=00;38;5;230:\
ln=01;38;5;140:\
pi=38;5;209:\
so=38;5;140:\
bd=38;5;209:\
cd=38;5;209:\
or=38;5;168:\
mi=38;5;168:\
ex=01;38;5;150:\
*.tar=38;5;222:\
*.tgz=38;5;222:\
*.arc=38;5;222:\
*.arj=38;5;222:\
*.taz=38;5;222:\
*.lha=38;5;222:\
*.lz4=38;5;222:\
*.lzh=38;5;222:\
*.lzma=38;5;222:\
*.tlz=38;5;222:\
*.txz=38;5;222:\
*.tzo=38;5;222:\
*.t7z=38;5;222:\
*.zip=38;5;222:\
*.z=38;5;222:\
*.dz=38;5;222:\
*.gz=38;5;222:\
*.lrz=38;5;222:\
*.lz=38;5;222:\
*.lzo=38;5;222:\
*.xz=38;5;222:\
*.zst=38;5;222:\
*.tzst=38;5;222:\
*.bz2=38;5;222:\
*.bz=38;5;222:\
*.tbz=38;5;222:\
*.tbz2=38;5;222:\
*.tz=38;5;222:\
*.deb=38;5;222:\
*.rpm=38;5;222:\
*.jar=38;5;222:\
*.war=38;5;222:\
*.ear=38;5;222:\
*.sar=38;5;222:\
*.rar=38;5;222:\
*.alz=38;5;222:\
*.ace=38;5;222:\
*.zoo=38;5;222:\
*.cpio=38;5;222:\
*.7z=38;5;222:\
*.rz=38;5;222:\
*.cab=38;5;222:\
*.wim=38;5;222:\
*.swm=38;5;222:\
*.dwm=38;5;222:\
*.esd=38;5;222:\
*.jpg=38;5;73:\
*.jpeg=38;5;73:\
*.mjpg=38;5;73:\
*.mjpeg=38;5;73:\
*.gif=38;5;73:\
*.bmp=38;5;73:\
*.pbm=38;5;73:\
*.pgm=38;5;73:\
*.ppm=38;5;73:\
*.tga=38;5;73:\
*.xbm=38;5;73:\
*.xpm=38;5;73:\
*.tif=38;5;73:\
*.tiff=38;5;73:\
*.png=38;5;73:\
*.svg=38;5;73:\
*.svgz=38;5;73:\
*.mng=38;5;73:\
*.pcx=38;5;73:\
*.webp=38;5;73:\
*.ogv=38;5;218:\
*.mp4=38;5;218:\
*.m4v=38;5;218:\
*.mp4v=38;5;218:\
*.vob=38;5;218:\
*.qt=38;5;218:\
*.nuv=38;5;218:\
*.wmv=38;5;218:\
*.asf=38;5;218:\
*.rm=38;5;218:\
*.rmvb=38;5;218:\
*.flc=38;5;218:\
*.avi=38;5;218:\
*.fli=38;5;218:\
*.flv=38;5;218:\
*.gl=38;5;218:\
*.dl=38;5;218:\
*.xcf=38;5;218:\
*.xwd=38;5;218:\
*.yuv=38;5;218:\
*.cgm=38;5;218:\
*.emf=38;5;218:\
*.ogx=38;5;218:\
*.mov=38;5;218:\
*.mpg=38;5;218:\
*.mpeg=38;5;218:\
*.m2v=38;5;218:\
*.mkv=38;5;218:\
*.webm=38;5;218:\
*.ogm=38;5;218:\
*.mp3=38;5;209:\
*.flac=38;5;209:\
*.m4a=38;5;209:\
*.mid=38;5;209:\
*.midi=38;5;209:\
*.mka=38;5;209:\
*.mpc=38;5;209:\
*.ogg=38;5;209:\
*.ra=38;5;209:\
*.wav=38;5;209:\
*.oga=38;5;209:\
*.opus=38;5;209:\
*.spx=38;5;209:\
*.xspf=38;5;209:\
*.pdf=38;5;117:\
*.ps=38;5;117:\
*.txt=38;5;230:\
*.md=38;5;117:\
*.doc=38;5;117:\
*.docx=38;5;117:\
*.odt=38;5;117:\
*.rtf=38;5;117:\
*.tex=38;5;117:\
*.epub=38;5;117:\
*.org=38;5;117:\
*.adoc=38;5;117:\
*.rst=38;5;117:\
*.py=38;5;110:\
*.pyc=38;5;240:\
*.pyo=38;5;240:\
*.pyd=38;5;240:\
*.rb=38;5;168:\
*.js=38;5;110:\
*.jsx=38;5;110:\
*.ts=38;5;110:\
*.tsx=38;5;110:\
*.html=38;5;110:\
*.htm=38;5;110:\
*.css=38;5;110:\
*.scss=38;5;110:\
*.sass=38;5;110:\
*.less=38;5;110:\
*.json=38;5;110:\
*.xml=38;5;110:\
*.yaml=38;5;110:\
*.yml=38;5;110:\
*.toml=38;5;110:\
*.ini=38;5;110:\
*.cfg=38;5;110:\
*.conf=38;5;110:\
*.sh=38;5;150:\
*.bash=38;5;150:\
*.zsh=38;5;150:\
*.fish=38;5;150:\
*.c=38;5;110:\
*.h=38;5;110:\
*.cpp=38;5;110:\
*.hpp=38;5;110:\
*.cc=38;5;110:\
*.cxx=38;5;110:\
*.java=38;5;110:\
*.go=38;5;110:\
*.rs=38;5;110:\
*.php=38;5;110:\
*.lua=38;5;110:\
*.vim=38;5;110:\
*.sql=38;5;110:\
*.r=38;5;110:\
*.R=38;5;110:\
*.pl=38;5;110:\
*.pm=38;5;110:\
*.swift=38;5;110:\
*.kt=38;5;110:\
*.scala=38;5;110:\
*.hs=38;5;110:\
*.elm=38;5;110:\
*.ex=38;5;110:\
*.exs=38;5;110:\
*.clj=38;5;110:\
*.cljs=38;5;110:\
*.coffee=38;5;110:\
*.dockerfile=38;5;110:\
*.Dockerfile=38;5;110:\
*.makefile=38;5;110:\
*.Makefile=38;5;110:\
*.mk=38;5;110:\
*.cmake=38;5;110:\
*.lock=38;5;240:\
*.log=38;5;240:\
*.tmp=38;5;240:\
*.bak=38;5;240:\
*.swp=38;5;240:\
*.swo=38;5;240:\
*.swn=38;5;240:\
"

# Export for other tools that use LS_COLORS
export LS_COLORS

# Note: zsh completion colors are configured in zsh_completion.zsh
# using: zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# This ensures completions use the same Catppuccin Frappe colors

