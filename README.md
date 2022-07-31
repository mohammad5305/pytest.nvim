# Pytest.nvim

## Description
`pytest.nvim`  is an plugin for running tests asynchronously and making test snippet based on treesitter

## Installation

[vim-plug](https://github.com/junegunn/vim-plug)

```
Plug 'mohammad5305/pytest.nvim'

lua << EOF
require("pytest").setup()
EOF
```

[packer](https://github.com/wbthomason/packer.nvim)

```
use {
    'mohammad5305/pytest.nvim',
    config = function () require('pytest').setup() end
}
```

## Contributing
Read [CONTRIBUTING.md](CONTRIBUTING.md)


## TODO
* separate class snippet and function snippet
* making tests directory if not exist
* putting snippet in file on tests directory
* put result of tests on signcolumn 
* write CONTRIBUTING file
