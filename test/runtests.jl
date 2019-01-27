using TableOperations, Test

ctable = (A=[1, missing, 3], B=[1.0, 2.0, 3.0], C=["hey", "there", "sailor"])

## TableOperations.transform
# test various ways of inputting TableOperations.transform functions
table = TableOperations.transform(ctable, Dict{String, Base.Callable}("C" => Symbol)) |> Tables.columntable
@test table.C == [:hey, :there, :sailor]

table = ctable |> TableOperations.transform(C=Symbol) |> Tables.columntable
@test table.C == [:hey, :there, :sailor]

table = TableOperations.transform(ctable, Dict{Symbol, Base.Callable}(:C => Symbol)) |> Tables.columntable
@test table.C == [:hey, :there, :sailor]

table = TableOperations.transform(ctable, Dict{Int, Base.Callable}(3 => Symbol)) |> Tables.columntable
@test table.C == [:hey, :there, :sailor]

# test simple TableOperations.transforms + return types
table = ctable |> TableOperations.transform(Dict("A"=>x->x+1)) |> Tables.columntable
@test isequal(table.A, [2, missing, 4])
@test typeof(table.A) == Vector{Union{Missing, Int}}

table = ctable |> TableOperations.transform(Dict("A"=>x->coalesce(x+1, 0))) |> Tables.columntable
@test table.A == [2, 0, 4]

table = ctable |> TableOperations.transform(Dict("A"=>x->coalesce(x+1, 0.0))) |> Tables.columntable
@test table.A == [2, 0.0, 4]

table = ctable |> TableOperations.transform(Dict(2=>x->x==2.0 ? missing : x)) |> Tables.columntable
@test isequal(table.B, [1.0, missing, 3.0])
@test typeof(table.B) == Vector{Union{Float64, Missing}}

# test row sinks
# test various ways of inputting TableOperations.transform functions
table = TableOperations.transform(ctable, Dict{String, Base.Callable}("C" => Symbol)) |> Tables.rowtable
@test table[1].C == :hey

table = ctable |> TableOperations.transform(C=Symbol) |> Tables.rowtable
@test table[1].C == :hey

table = TableOperations.transform(ctable, Dict{Symbol, Base.Callable}(:C => Symbol)) |> Tables.rowtable
@test table[1].C == :hey

table = TableOperations.transform(ctable, Dict{Int, Base.Callable}(3 => Symbol)) |> Tables.rowtable
@test table[1].C == :hey

# test simple transforms + return types
table = ctable |> TableOperations.transform(Dict("A"=>x->x+1)) |> Tables.rowtable
@test isequal(map(x->x.A, table), [2, missing, 4])
@test typeof(map(x->x.A, table)) == Vector{Union{Missing, Int}}

table = ctable |> TableOperations.transform(Dict("A"=>x->coalesce(x+1, 0))) |> Tables.rowtable
@test map(x->x.A, table) == [2, 0, 4]

table = ctable |> TableOperations.transform(Dict("A"=>x->coalesce(x+1, 0.0))) |> Tables.rowtable
@test map(x->x.A, table) == [2, 0.0, 4]

table = ctable |> TableOperations.transform(Dict(2=>x->x==2.0 ? missing : x)) |> Tables.rowtable
@test isequal(map(x->x.B, table), [1.0, missing, 3.0])
@test typeof(map(x->x.B, table)) == Vector{Union{Float64, Missing}}

## TableOperations.select
table = ctable |> TableOperations.select(:A) |> Tables.columntable
@test length(table) == 1
@test isequal(table.A, [1, missing, 3])

table = ctable |> TableOperations.select("A") |> Tables.columntable
@test length(table) == 1
@test isequal(table.A, [1, missing, 3])

# column re-ordering
table = ctable |> TableOperations.select(:A, :C) |> Tables.columntable
@test length(table) == 2

table = ctable |> TableOperations.select(:C, :A) |> Tables.columntable
@test isequal(ctable.A, table.A)
@test isequal(ctable[1], table[2])

# row sink
table = ctable |> TableOperations.select(:A) |> Tables.rowtable
@test length(table[1]) == 1
@test isequal(map(x->x.A, table), [1, missing, 3])

table = ctable |> TableOperations.select("A") |> Tables.rowtable
@test length(table[1]) == 1
@test isequal(map(x->x.A, table), [1, missing, 3])

# column re-ordering
table = ctable |> TableOperations.select(:A, :C) |> Tables.rowtable
@test length(table[1]) == 2

table = ctable |> TableOperations.select(:C, :A) |> Tables.rowtable
@test isequal(ctable.A, map(x->x.A, table))
@test isequal(ctable[1], map(x->x[2], table))
