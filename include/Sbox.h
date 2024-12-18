#ifndef SBOX_H
#define SBOX_H

#include "defines.h"

class Sbox {
private:
  sbox_matrix matrix;

public:
  Sbox(sbox_matrix matrix);
  quarter_block apply(half_block bloco);

private:
  ull get_row_bits(half_block bloco) const;
  ull get_col_bits(half_block bloco) const;
};
#endif // !SBOX_H
