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
* better asking style when opts[testDir] not exist
* test multi function and more docstring
* checking for performance when putting user commands in setup()
* distinct the report string
