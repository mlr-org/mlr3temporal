% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/MeasureForecastRMSE.R
\name{mlr_measures_forecast.rmse}
\alias{mlr_measures_forecast.rmse}
\alias{MeasureForecastRMSE}
\title{Root Mean Squared Error Measure}
\description{
Root Mean Squared Error Measure

Root Mean Squared Error Measure
}
\section{Dictionary}{

This \link{Measure} can be instantiated via the \link[mlr3misc:Dictionary]{dictionary} \link{mlr_measures} or with the associated sugar function \code{\link[=msr]{msr()}}:

\if{html}{\out{<div class="sourceCode">}}\preformatted{mlr_measures$get("forecast.rmse")
msr("forecast.rmse")
}\if{html}{\out{</div>}}
}

\section{Meta Information}{

\itemize{
\item Task type: \dQuote{forecast}
\item Range: \eqn{[0, \infty)}{[0, Inf)}
\item Minimize: TRUE
\item Average: macro
\item Required Prediction: \dQuote{response}
\item Required Packages: \CRANpkg{mlr3}, \CRANpkg{mlr3temporal}
}
}

\section{Parameters}{

Empty ParamSet
}

\seealso{
\itemize{
\item Chapter in the \href{https://mlr3book.mlr-org.com/}{mlr3book}:
\url{https://mlr3book.mlr-org.com/basics.html#train-predict}
\item Package \CRANpkg{mlr3measures} for the scoring functions.
\link[mlr3misc:Dictionary]{Dictionary} of \link[=Measure]{Measures}: \link{mlr_measures}
\code{as.data.table(mlr_measures)} for a table of available \link[=Measure]{Measures} in the running session (depending on the loaded packages).
\item Extension packages for additional task types:
\itemize{
\item \CRANpkg{mlr3proba} for probabilistic supervised regression and survival analysis.
\item \CRANpkg{mlr3cluster} for unsupervised clustering.
}
}

Other Measure: 
\code{\link{MeasureForecast}},
\code{\link{mlr_measures_forecast.mae}},
\code{\link{mlr_measures_forecast.mape}},
\code{\link{mlr_measures_forecast.mse}},
\code{\link{mlr_measures_forecast.regr}}
}
\concept{Measure}
\section{Super classes}{
\code{\link[mlr3:Measure]{mlr3::Measure}} -> \code{\link[mlr3temporal:MeasureForecast]{mlr3temporal::MeasureForecast}} -> \code{\link[mlr3temporal:MeasureForecastRegr]{mlr3temporal::MeasureForecastRegr}} -> \code{MeasureForecastRMSE}
}
\section{Methods}{
\subsection{Public methods}{
\itemize{
\item \href{#method-MeasureForecastRMSE-new}{\code{MeasureForecastRMSE$new()}}
\item \href{#method-MeasureForecastRMSE-clone}{\code{MeasureForecastRMSE$clone()}}
}
}
\if{html}{\out{
<details open><summary>Inherited methods</summary>
<ul>
<li><span class="pkg-link" data-pkg="mlr3" data-topic="Measure" data-id="aggregate"><a href='../../mlr3/html/Measure.html#method-Measure-aggregate'><code>mlr3::Measure$aggregate()</code></a></span></li>
<li><span class="pkg-link" data-pkg="mlr3" data-topic="Measure" data-id="format"><a href='../../mlr3/html/Measure.html#method-Measure-format'><code>mlr3::Measure$format()</code></a></span></li>
<li><span class="pkg-link" data-pkg="mlr3" data-topic="Measure" data-id="help"><a href='../../mlr3/html/Measure.html#method-Measure-help'><code>mlr3::Measure$help()</code></a></span></li>
<li><span class="pkg-link" data-pkg="mlr3" data-topic="Measure" data-id="print"><a href='../../mlr3/html/Measure.html#method-Measure-print'><code>mlr3::Measure$print()</code></a></span></li>
<li><span class="pkg-link" data-pkg="mlr3" data-topic="Measure" data-id="score"><a href='../../mlr3/html/Measure.html#method-Measure-score'><code>mlr3::Measure$score()</code></a></span></li>
</ul>
</details>
}}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-MeasureForecastRMSE-new"></a>}}
\if{latex}{\out{\hypertarget{method-MeasureForecastRMSE-new}{}}}
\subsection{Method \code{new()}}{
Creates a new instance of this \link[R6:R6Class]{R6} class.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{MeasureForecastRMSE$new()}\if{html}{\out{</div>}}
}

}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-MeasureForecastRMSE-clone"></a>}}
\if{latex}{\out{\hypertarget{method-MeasureForecastRMSE-clone}{}}}
\subsection{Method \code{clone()}}{
The objects of this class are cloneable with this method.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{MeasureForecastRMSE$clone(deep = FALSE)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{deep}}{Whether to make a deep clone.}
}
\if{html}{\out{</div>}}
}
}
}
