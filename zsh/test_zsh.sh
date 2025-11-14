#!/usr/bin/env bash
# test_zsh.sh - Test zsh configuration
# Verifies that all zsh configs are set up correctly

echo "🧪 Testing Zsh Configuration"
echo "============================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS=0
FAIL=0

# Test function
test_check() {
    local name="$1"
    local command="$2"
    
    if eval "$command" &>/dev/null; then
        echo -e "${GREEN}✅${NC} $name"
        ((PASS++))
        return 0
    else
        echo -e "${RED}❌${NC} $name"
        ((FAIL++))
        return 1
    fi
}

# Test zsh installation
echo "📦 Checking zsh installation..."
if command -v zsh &>/dev/null; then
    echo -e "${GREEN}✅${NC} zsh is installed: $(zsh --version | head -1)"
    ((PASS++))
else
    echo -e "${RED}❌${NC} zsh is not installed"
    echo "   Install with: sudo pacman -S zsh"
    ((FAIL++))
fi
echo ""

# Test configuration files
echo "📁 Checking configuration files..."
test_check "zsh_completion.zsh exists" "[ -f ~/.config/zsh/zsh_completion.zsh ]"
test_check "zsh_colors.zsh exists" "[ -f ~/.config/zsh/zsh_colors.zsh ]"
test_check "fzf_integration.zsh exists" "[ -f ~/.config/zsh/fzf_integration.zsh ]"
echo ""

# Test if we can source the files (syntax check)
echo "🔍 Checking file syntax..."
if zsh -n ~/.config/zsh/zsh_completion.zsh 2>/dev/null; then
    echo -e "${GREEN}✅${NC} zsh_completion.zsh syntax is valid"
    ((PASS++))
else
    echo -e "${RED}❌${NC} zsh_completion.zsh has syntax errors"
    zsh -n ~/.config/zsh/zsh_completion.zsh 2>&1 | head -5
    ((FAIL++))
fi

if zsh -n ~/.config/zsh/zsh_colors.zsh 2>/dev/null; then
    echo -e "${GREEN}✅${NC} zsh_colors.zsh syntax is valid"
    ((PASS++))
else
    echo -e "${RED}❌${NC} zsh_colors.zsh has syntax errors"
    zsh -n ~/.config/zsh/zsh_colors.zsh 2>&1 | head -5
    ((FAIL++))
fi

if zsh -n ~/.config/zsh/fzf_integration.zsh 2>/dev/null; then
    echo -e "${GREEN}✅${NC} fzf_integration.zsh syntax is valid"
    ((PASS++))
else
    echo -e "${RED}❌${NC} fzf_integration.zsh has syntax errors"
    zsh -n ~/.config/zsh/fzf_integration.zsh 2>&1 | head -5
    ((FAIL++))
fi
echo ""

# Test dependencies
echo "🔧 Checking dependencies..."
test_check "fzf is installed" "command -v fzf"
test_check "starship is installed" "command -v starship"
echo ""

# Test if .zshrc exists
echo "📝 Checking .zshrc..."
if [ -f ~/.zshrc ]; then
    echo -e "${GREEN}✅${NC} .zshrc exists"
    ((PASS++))
    
    # Check if it sources our configs
    if grep -q "zsh_completion.zsh" ~/.zshrc; then
        echo -e "${GREEN}✅${NC} .zshrc sources zsh_completion.zsh"
        ((PASS++))
    else
        echo -e "${YELLOW}⚠️${NC}  .zshrc doesn't source zsh_completion.zsh"
        echo "   Add: if [ -f ~/.config/zsh/zsh_completion.zsh ]; then . ~/.config/zsh/zsh_completion.zsh; fi"
        ((FAIL++))
    fi
else
    echo -e "${YELLOW}⚠️${NC}  .zshrc doesn't exist"
    echo "   Create it with the template in TESTING.md"
    ((FAIL++))
fi
echo ""

# Test if we can actually run zsh and load configs
echo "🚀 Testing zsh execution..."
if command -v zsh &>/dev/null; then
    # Try to source configs in a test zsh session
    if zsh -c 'source ~/.config/zsh/zsh_colors.zsh 2>/dev/null && [ -n "$LS_COLORS" ]' 2>/dev/null; then
        echo -e "${GREEN}✅${NC} zsh can load zsh_colors.zsh"
        ((PASS++))
    else
        echo -e "${RED}❌${NC} zsh cannot load zsh_colors.zsh"
        ((FAIL++))
    fi
    
    if zsh -c 'source ~/.config/zsh/zsh_completion.zsh 2>/dev/null && autoload -Uz compinit && compinit -D 2>/dev/null' 2>/dev/null; then
        echo -e "${GREEN}✅${NC} zsh can load zsh_completion.zsh"
        ((PASS++))
    else
        echo -e "${RED}❌${NC} zsh cannot load zsh_completion.zsh"
        ((FAIL++))
    fi
else
    echo -e "${RED}❌${NC} Cannot test - zsh not installed"
    ((FAIL++))
fi
echo ""

# Summary
echo "============================"
echo "📊 Test Summary"
echo "============================"
echo -e "${GREEN}Passed:${NC} $PASS"
echo -e "${RED}Failed:${NC} $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Start zsh: zsh"
    echo "2. Test menu selection: git <TAB> (use arrow keys)"
    echo "3. Test fzf: Ctrl+R (history search)"
    exit 0
else
    echo -e "${YELLOW}⚠️  Some tests failed${NC}"
    echo ""
    echo "See TESTING.md for troubleshooting"
    exit 1
fi

