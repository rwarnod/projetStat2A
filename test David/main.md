# Introduction

# cas d'une droite d'étalonnage

Soit x la concentration et y le résultat de la mesure physique. Dans le
cas d'une courbe d'étalonnage linéaire la relation est donnée par :
$$y = \beta_{0} + \beta_{1}x + \epsilon$$
$$y_i = \beta_{0} + \beta_{1}x_i + \epsilon_i$$

Une fois la machine étalonnée on ne cherche pas à évaluer la
concentration en fonction de la mesure physique, mais l'inverse :
$$\hat{x} = \frac{y - \hat{\beta_{0}}}{\hat{\beta_{1}}}$$

Cette équation pose quelques problèmes. Elle défini un estimateur de x
qui est biaisé, dont la loi n'est pas une loi bien connue et dont la
variance est par conséquent difficile à estimer. Pour pallier à ces
difficultés nous allons faire les l'hypothèse que l'estimation de
$\beta_0$ et $\beta_1$ sont très proche de leurs valeurs réelles. Cette
hypothèse pourra être contrôler à posteriori. Ainsi, on peut approcher
$\hat{x}$ par un développement limité d'ordre 1 :

$$\hat{x} \approx \frac{y - \beta_{0}}{\beta_{1}} - \frac{1}{\beta_{1}}(\hat{\beta_{0}} - \beta_{0}) -\frac{y - \beta_{0}}{\beta_{1}^2} (\hat{\beta_{1}} - \beta_{1})$$

En remplaçant par y par $\beta_{0} + \beta_{1}x + \epsilon$ on obtient :
$$\hat{x} \approx x -\frac{\epsilon}{\beta_{1}} - \frac{1}{\beta_{1}}(\hat{\beta_{0}} - \beta_{0}) - \frac{x}{\beta_{1}} (\hat{\beta_{1}} - \beta_{1}) - \frac{\epsilon}{\beta_{1}} (\hat{\beta_{1}} - \beta_{1})$$

Enfin en négligeant le terme d'erreur d'ordre 2
$\frac{\epsilon}{\beta_{1}} (\hat{\beta_{1}} - \beta_{1})$ on obtient :
$$\hat{x} \approx x  - \frac{1}{\beta_{1}}(\hat{\beta_{0}} - \beta_{0}) - \frac{x}{\beta_{1}} (\hat{\beta_{1}} - \beta_{1})   -\frac{\epsilon}{\beta_{1}}$$
Ainsi, $\hat{x}$ est un estimateur approximativement sans biais,
approximativement gaussien dont une la variance est approximativement :
$$var(\hat{x}) \approx \frac{1}{\beta_{1}^2}(var(\hat{\beta_{0}}) + x^2*var(\hat{\beta_{1}}) + 2x*cov(\hat{\beta_{0}},\hat{\beta_{1}}) + var(\epsilon))$$

En notant $D=n\sum_{i=1}^n x_i^2 - \left(\sum_{i=1}^n x_i \right)^2$ et
$\sigma^2_y$ la variance de y on obtient :
$$var(\hat{x}) \approx \frac{\sigma_y^2}{\beta_{1}^2} \left(\frac{1}{D}\left(\sum_{i=1}^n x_i^2 + x^2n - 2x \sum_{i=1}^n x_i\right) + 1\right)$$

$$var(\hat{x}) \approx \frac{\sigma_y^2}{\beta_{1}^2} \left(1 + \frac{1}{nD}\left(n\sum_{i=1}^n x_i^2 - \left(\sum_{i=1}^n x_i \right)^2 + \left(\sum_{i=1}^n x_i \right)^2  + x^2n^2 - 2xn \sum_{i=1}^n x_i\right) \right)$$

$$var(\hat{x}) \approx \frac{\sigma_y^2}{\beta_{1}^2} \left(1 + \frac{1}{n} + \frac{(nx - \sum_{i=1}^n x_i)^2}{nD} \right)$$

Dans le cas d'une mesure répété k fois, si l'on utilise la moyenne des k
résultats obtenus comme estimation de x seule par de variance due à
l'incertitude sur y est modifié. En notant $\eta_i$ i variant de 1 à k
les termes d'erreur, il suffit de remplacer dans les équation
précédentes $var(\epsilon)$ par
$\frac{1}{k}var(\sum_{i=1}^k\eta_i) = \frac{\sigma^2_y}{k}$ et l'on
obtient :
$$var(\hat{x}) \approx \frac{\sigma_y^2}{\beta_{1}^2} \left(\frac{1}{k} + \frac{1}{n} + \frac{(nx - \sum_{i=1}^n x_i)^2}{nD} \right)$$

## limite de blanc

Deux cas peuvent être distingués pour calculer la limite de blanc. On
peut soit utiliser les données qui on permis de construire la courbe
d'étalonnage, soit utiliser des mesures de blancs dédiés à l'estimation
de la limite de blanc.

### Utilisation de mesures dédiés

Sous l'hypothèse que les mesures de blanc sont des réalisation d'une
variable aléatoire gaussienne de moyenne $y_0$ et d'écart type
$\sigma_y$, soient $\hat{y_0} = \frac{1}{n}\sum_{i=1}^n y_i$ et
$\hat{\sigma_y}=\frac{\sum_{i=1}^n(yi-\hat{y_0}}{n-1}$ leurs estimateurs
respectifs, $\frac{\hat{y_0}-y_0}{\hat{\sigma_y}}$ suit une loi de
Student à n-1 degrés de liberté. On peut donc estimer que $\alpha \%$
des mesures de blancs seront inférieur à
$t_{n-1}(\alpha)\hat{\sigma_y}$. Ainsi la limite de blanc au niveau de
confiance $\alpha$ sera donnée par :
$$LOB =  \frac{t_{n-1}(\alpha)\hat{\sigma_y}-\hat{\beta_0}}{\hat{\beta_{1}}}$$

### Utilisation des données d'étalonnage

Lorsqu'on de dispose pas de mesures dédiées à l'estimation de la limite
de blanc, elle peut être estimée à partir des données utilisés pour
construire la courbe d'étalonnage. Nous avons donner un estimateur d'une
concentration x approximativement sans biais et gaussien de variance :
$$\sigma_x^2 \approx \frac{\sigma_y^2}{\beta_{1}^2} \left(1 + \frac{1}{n} + \frac{(nx - \sum_{i=1}^n x_i)^2}{nD} \right)$$
On peut estimer cette variance en remplaçant dans cette équation
$\sigma_y$ ET $\beta_1$ par leurs estimations. En négligeant la
variabilité de $\hat{\beta_1}$, $\frac{x -\hat{x}}{\hat{\sigma_x}}$ suit
une loi de Student à n-1 de degrés de liberté. (j'ai fait cette
hypothèse pour retrouver le résultat de la doc mais à vérifier que je ne
fais pas n'importe quoi). Ainsi la limite de blanc pour un niveau de
confiance $\alpha$ peut être estimée par :
$$LOB = t_{n-1}(\alpha)\frac{\hat{\sigma_y}}{\hat{\beta_{1}}} \sqrt{1 + \frac{1}{n} + \frac{( \sum_{i=1}^n x_i)^2}{nD} } \ $$

# limite de détection

En utilisant à nouveau le fait que $\frac{x -\hat{x}}{\hat{\sigma_x}}$
suit une loi de Student à n-1 de degrés de liberté la limite de
détection au niveau de confiance $\alpha$ la limite de détection sera
solution de l'équation en x :
$$LOB = x - t_{n-1}(1-\alpha)\frac{\hat{\sigma_y}}{\hat{\beta_{1}}} \sqrt{1 + \frac{1}{n} + \frac{(x \sum_{i=1}^n x_i)^2}{nD} } \ $$
et donc solution de l'équation polynomiale de degré 2 en x :
$$(LOB - x)^2 - t_{n-1}^2(1-\alpha)\frac{\hat{\sigma_y}^2}{\hat{\beta_{1}}^2} \left(1 + \frac{1}{n} + \frac{(nx -\sum_{i=1}^n x_i)^2}{nD} \right) = 0$$
On conservera la plus petite solution supérieure à LOB. A voir si l'on
peut montrer qu'on à une solution supérieur à LOB et une inférieur.

Dans l'article une formule est proposée en supposant $\sigma^2_x$
constant. Voir si cette hypothèse est réaliste pour les données qui nous
sont fournies.

## Limites de quantification

## Pour une précision absolue

Soit p la précision souhaitée et $\alpha$ le niveau de confiance auquel
au souhaite que cette précision soit atteinte. Cette précision sera
atteinte si la demi longueur de l'intervalle de confiance associé à x
est inférieure ou égale à p :
$$t_{n-1}(1-\frac{\alpha}{2})\frac{\hat{\sigma_y}}{\hat{\beta_{1}}} \sqrt{1 + \frac{1}{n} + \frac{(x \sum_{i=1}^n x_i)^2}{nD} } \leq p$$

Les limites de quantifications seront les solutions de l'équation
polynomiale du second degré :
$$t_{n-1}^2(1-\frac{\alpha}{2})\frac{\hat{\sigma_y}^2}{\hat{\beta_{1}}^2} \left(1 + \frac{1}{n} + \frac{(nx -\sum_{i=1}^n x_i)^2}{nD} \right) = p^2$$

## Pour une précision relative

Pour estimer la précision relative associé à une mesure, l'usage est
d'utiliser le coefficient de variation. Ainsi un précision relative r
sera obtenue lorsque : $$cv(x) = \frac{\sigma_x}{x} \leq r$$ Les limites
de quantifications seront les solutions de l'équation polynomiale du
second degré :
$$\frac{\hat{\sigma_y}^2}{\hat{\beta_{1}}^2} \left(1 + \frac{1}{n} + \frac{(nx -\sum_{i=1}^n x_i)^2}{nD} \right) = r^2x^2$$
Si l'on souhaite associé un niveau de confiance $\alpha$ aux limites de
quantification relative on chercher les solution de l'équation :
$$t_{n-1}^2(1-\frac{\alpha}{2})\frac{\hat{\sigma_y}^2}{\hat{\beta_{1}}^2} \left(1 + \frac{1}{n} + \frac{(nx -\sum_{i=1}^n x_i)^2}{nD} \right) = r^2x^2$$

# Conclusion
