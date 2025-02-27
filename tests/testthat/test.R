test_that("list()", {
    x <- OSTA.data_list()
    expect_type(x, "character")
})

test_that("load()", {
    # check 'BiocFileCache'ing
    require(BiocFileCache(), quietly=TRUE)
    id <- "Visium_HumanBreast_Janesick"
    ca <- \(id) bfcquery(BiocFileCache(), id)
    # assure cache is cleared
    bfc <- BiocFileCache()
    bfcremove(bfc, ca(id)$rid)
    expect_equal(nrow(ca(id)), 0)
    # loading should cache
    pa <- OSTA.data_load(id)
    expect_equal(nrow(ca(id)), 1)
    # invalid dataset identifier
    expect_error(OSTA.data_load(id=""))
})

spe <- "SpatialExperiment"
sce <- "SingleCellExperiment"

test_that("read,cos", {
    id <- "CosMx1k_MouseBrain1"
    se <- OSTA.data_read(id, mol=FALSE)
    expect_s4_class(se, spe)
    expect_true(!is.null(se$Annotation))
    
    # id <- "CosMx1k_MouseBrain2"
    # se <- OSTA.data_read(id, mol=FALSE)
    # expect_s4_class(se, spe)
    # expect_true(!is.null(se$Annotation))
    
    # id <- "CosMx6k_HumanBrain"
    # se <- OSTA.data_read(id, mol=FALSE)
    # expect_s4_class(se, spe)
})

test_that("read,chr", {
    id <- "Chromium_HumanBreast_Janesick"
    se <- OSTA.data_read(id)
    expect_s4_class(se, sce)
    expect_true(!is.null(se$Annotation))
    
    id <- "Chromium_HumanColon_Oliveira"
    se <- OSTA.data_read(id)
    expect_s4_class(se, sce)
    expect_true(!is.null(se$Patient))
})

test_that("read,vis", {
    id <- "Visium_HumanBreast_Janesick"
    se <- OSTA.data_read(id)
    expect_s4_class(se, sce)
    
    # id <- "Visium_HumanColon_Oliveira"
    # se <- OSTA.data_read(id)
    # expect_s4_class(se, sce)
    
    id <- "VisiumHD_HumanColon_Oliveira"
    se <- OSTA.data_read(id, bin=bs <- "016")
    expect_s4_class(se, sce)
    expect_identical(se$bin_size[1], bs)
})

test_that("read,xen", {
    id <- "Xenium_HumanColon_Oliveira"
    se <- OSTA.data_read(id)
    expect_s4_class(se, spe)
    
    id <- "Xenium_HumanBreast1_Janesick"
    se <- OSTA.data_read(id)
    expect_s4_class(se, spe)
    expect_true(!is.null(se$Annotation))
    
    # id <- "Xenium_HumanBreast2_Janesick"
    # se <- OSTA.data_read(id)
    # expect_s4_class(se, spe)
    # expect_true(!is.null(se$Annotation))
})