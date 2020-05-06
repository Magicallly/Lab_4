program lab4;

{$APPTYPE CONSOLE}
{$R *.res}

Const
  MaxDig = 1000; { Максимальное количество цифр в массиве }
  Osn = 10000; { Основание системы счисления }

Type
  Tlong = Array [0 .. MaxDig] Of Integer;

Procedure ReadLong(Var A: Tlong);
Var
  ch: char;
  i: Integer;
Begin
  FillChar(A, SizeOf(A), 0);
  Read(ch);
  While Not(ch In ['0' .. '9']) Do
    Read(ch);
  { пропуск не цифр }
  While ch In ['0' .. '9'] Do      // перевод
  Begin
    For i := A[0] DownTo 1 Do
    Begin
      { "протаскивание" старшей цифры в числе из A[i] в младшую цифру числа из A[i+l] }
      A[i + 1] := A[i + 1] + (LongInt(A[i]) * 10) Div Osn;
      A[i] := (LongInt(A[i]) * 10) Mod Osn
    end;
    A[1] := A[1] + Ord(ch) - Ord('0');
    { прибавление младшей цифры к числу из А[1] }
    If A[A[0] + 1] > 0 Then
      Inc(A[0]);
    { изменение длины, число задействованных элементов массива А }
    Read(ch)
  end
end;

Procedure WriteLong(Const A: Tlong);       // вывод
Var
  ls, s: String;
  i: Integer;
Begin
  Str(Osn Div 10, ls);
  Write(A[A[0]]); { вывод старших цифр числа }
  For i := A[0] - 1 DownTo 1 Do
  Begin
    Str(A[i], s);
    While Length(s) < Length(ls) Do
      s := '0' + s;
    { дополнение незначащими нулями }
    Write(s);
  end;
  Writeln;
end;

Function More(Const A, B: Tlong; Const sdvig: Integer): Byte;  //определяет сдвиг
Var
  i: Integer;
Begin
  If A[0] > (B[0] + sdvig) Then
    More := 0
  Else If A[0] < (B[0] + sdvig) Then
    More := 1
  Else
  Begin
    i := A[0];
    While (i > sdvig) And (A[i] = B[i - sdvig]) Do
      Dec(i);
    If i = sdvig Then
    Begin
      More := 0;
      { совпадение чисел с учетом сдвига }
      For i := 1 To sdvig Do
        If A[i] > 0 Then
      More := 2;
      { числа равны, "хвост" числа А равен нулю }
    End
    Else
      More := Byte(A[i] < B[i - sdvig]);
  End;
End;

Procedure Mul(Const A: Tlong; Const k: LongInt; Var C: Tlong); // длинна р-ра, проверка 0
Var
  i: Integer;
Begin
  FillChar(C, SizeOf(C), 0);
  If k = 0 Then
    Inc(C[0]) { умножение на ноль }
  Else
  Begin
    For i := 1 To A[0] Do
    Begin
      C[i + 1] := (LongInt(A[i]) * k + C[i]) Div Osn;
      C[i] := (LongInt(A[i]) * k + C[i]) Mod Osn
    End;
    If C[A[0] + 1] > 0 Then
      C[0] := A[0] + 1
    Else
      C[0] := A[0]
  End
End;

Procedure Sub(Var A: Tlong; Const B: Tlong; Const sp: Integer);   //остаток от деления
Var
  i, j: Integer;
  { из А вычитаем В с учетом сдвига sp, результат вычитания в А }
Begin
  For i := 1 To B[0] Do
  Begin
    Dec(A[i + sp], B[i]);
    j := i;
    while (A[j + sp] < 0) and (j <= A[0]) Do
    Begin
      Inc(A[j + sp], Osn);
      Dec(A[j + sp + 1]);
      Inc(j);
    end;

  end;
  i := A[0];
  While (i > 1) And (A[i] = 0) Do
    Dec(i);
  A[0] := i
  { корректировка длины результата операции }
end;

Function FindBin(Var Ost: Tlong; Const B: Tlong; Const sp: Integer): LongInt; // целая часть
Var
  Down, Up: Word;
  C: Tlong;
Begin
  Down := 0;
  Up := Osn;
  While Up - 1 > Down Do
  Begin
    Mul(B, (Up + Down) Div 2, C);
    Case More(Ost, C, sp) Of
      0:
        Down := (Down + Up) Div 2;
      1:
        Up := (Up + Down) Div 2;
      2:
        Begin
          Up := (Up + Down) Div 2;
          Down := Up;
        End;
    End;
  End;
  Mul(B, (Up + Down) Div 2, C);
  If More(Ost, C, 0) = 0 Then
    Sub(Ost, C, sp)  { остаток от деления }
  else
  begin
    Sub(C, Ost, sp);
    Ost := C;
  end;
  FindBin := (Up + Down) Div 2; { целая часть частного }
end;

Procedure MakeDel(Const A, B: Tlong; Var Res, Ost: Tlong);  // деление для А больше В
Var
  sp: Integer;
Begin
  Ost := A;
  { первоначальное значение остатка }
  sp := A[0] - B[0];
  If More(A, B, sp) = 1 Then
    Dec(sp);
  { B*Osn>A, в результате одна цифра }
  Res[0] := sp + 1;
  While sp >= 0 Do
  Begin
    { очередная цифра результата }
    Res[sp + 1] := FindBin(Ost, B, sp);
    Dec(sp);
  End;
End;

Procedure Long_Div_Long(Const A, B: Tlong; Var Res, Ost: Tlong);  //реализация деления
Begin
  FillChar(Res, SizeOf(Res), 0);
  Res[0] := 1;
  FillChar(Ost, SizeOf(Ost), 0);
  Ost[0] := 1;
  Case More(A, B, 0) Of
    0:
      MakeDel(A, B, Res, Ost); { А больше В }
    1:
      Ost := A; { А меньше В }
    2:
      Res[1] := 1; { А равно В }
  End;
End;

Var
  A, B, C, D: Tlong;

Begin
  write ('Введите делимое: ');
  ReadLong(A);
  write ('Введите делитель: ');
  ReadLong(B);
  Long_Div_Long(A, B, C, D);
  write('Результат деления длинных чисел = ');
  WriteLong(C);
  write('Остаток от деления длинных чисел = ');
  WriteLong(D);

  readln;
  readln;

End.
